"""Build a non-destructive IUP import from the supplied permit PDF."""

import re
import sys
from datetime import datetime
from pathlib import Path

import pdfplumber


SKIP_PDF_ROWS = {26, 42, 44, 72}


def sql(value):
    if value is None or value == "":
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    return "'" + str(value).replace("'", "''") + "'"


def make_values(pdf_path):
    with pdfplumber.open(pdf_path) as pdf:
        records = [row for page in pdf.pages for row in page.extract_table()
                   if row[0] and row[0].isdigit()]
    if len(records) != 77 or [int(row[0]) for row in records] != list(range(1, 78)):
        raise ValueError("PDF rows differ from the reviewed 1-77 sequence")
    result = []
    for row in records:
        no, name, stage, permit, start, end, _, commodity, area, location = row
        if int(no) in SKIP_PDF_ROWS:
            continue
        start_date = datetime.strptime(start, "%d/%m/%Y").date()
        end_date = datetime.strptime(end, "%d/%m/%Y").date()
        if end_date <= start_date:
            raise ValueError(f"Unexpected date order on PDF row {no}")
        if stage not in ("IUP OP", "IUP Ekspl."):
            raise ValueError(f"Unexpected stage on PDF row {no}: {stage}")
        if not permit or not name or not location:
            raise ValueError(f"Required field missing on PDF row {no}")
        hectares = float(area.replace(".", "").replace(",", "."))
        fields = (name.strip(), stage, commodity.strip(), hectares,
                  location.strip(), permit.strip(), start_date.isoformat(),
                  end_date.isoformat())
        result.append("  (" + ", ".join(map(sql, fields)) + ")")
    return result


def main(pdf_path, destination):
    values = make_values(pdf_path)
    columns = "nama, status_iup, komoditas, luas_ha, lokasi, nomor_sk, tgl_mulai, tgl_berakhir"
    query = f"""-- Source: 1. DATA PEMEGANG IUP_2.pdf, 77 numbered records.
-- Rows 26 and 72 share a permit number but name different companies.
-- Rows 42, 44, 72 also have invalid/reversed dates in the PDF.
-- 73 records are checked against the live IUP table. No existing row is changed.
-- The permit number is the primary match; name + stage + dates + area catch
-- minor SK transcription differences. Safe to rerun sequentially.
BEGIN;
WITH source ({columns}) AS (VALUES
{',\n'.join(values)}
)
INSERT INTO public.iup ({columns})
SELECT s.nama, s.status_iup, s.komoditas, s.luas_ha, s.lokasi, s.nomor_sk,
       s.tgl_mulai::date, s.tgl_berakhir::date FROM source s
WHERE NOT EXISTS (
  SELECT 1 FROM public.iup d
  WHERE regexp_replace(regexp_replace(upper(coalesce(d.nomor_sk, '')), '[^A-Z0-9]', '', 'g'), '^NO', '') =
        regexp_replace(regexp_replace(upper(coalesce(s.nomor_sk, '')), '[^A-Z0-9]', '', 'g'), '^NO', '')
     OR (
       regexp_replace(upper(coalesce(d.nama, '')), '[^A-Z0-9]', '', 'g') =
         regexp_replace(upper(coalesce(s.nama, '')), '[^A-Z0-9]', '', 'g')
       AND d.status_iup = s.status_iup
       AND d.tgl_mulai::date = s.tgl_mulai::date
       AND d.tgl_berakhir::date = s.tgl_berakhir::date
       AND regexp_replace(upper(coalesce(d.lokasi, '')), '[^A-Z0-9]', '', 'g') =
           regexp_replace(upper(coalesce(s.lokasi, '')), '[^A-Z0-9]', '', 'g')
       AND abs(coalesce(d.luas_ha, 0) - s.luas_ha) <= 1
     )
);
COMMIT;
"""
    Path(destination).write_text(query, encoding="utf-8")
    print(f"Prepared {len(values)} checked IUP records; 4 conflicting/invalid rows withheld")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
