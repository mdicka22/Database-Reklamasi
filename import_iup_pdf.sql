-- Source: 1. DATA PEMEGANG IUP_2.pdf, 77 numbered records.
-- Rows 26 and 72 share a permit number but name different companies.
-- Rows 42, 44, 72 also have invalid/reversed dates in the PDF.
-- 73 records are checked against the live IUP table. No existing row is changed.
-- The permit number is the primary match; name + stage + dates + area catch
-- minor SK transcription differences. Safe to rerun sequentially.
BEGIN;
WITH source (nama, status_iup, komoditas, luas_ha, lokasi, nomor_sk, tgl_mulai, tgl_berakhir) AS (VALUES
  ('PT. PIYEUNG MINING', 'IUP OP', 'Bijih Besi', 195.37, 'Aceh Besar', 'No. 540/DPMPTSP/1627/IUP-OP./2019', '2019-05-31', '2029-05-31'),
  ('PT. LHOONG SETIA MINING', 'IUP OP', 'Bijih Besi', 500.0, 'Aceh Besar', 'No. 540/DPMPTSP/909/IUP-OP1./2024', '2024-08-15', '2035-03-20'),
  ('PT. SAMANA CITRA AGUNG', 'IUP OP', 'Pasir Besi', 120.6, 'Aceh Besar', 'No. 540/DPMPTSP/3527/IUP-OP2./2020', '2020-11-26', '2030-11-26'),
  ('PT SULTAN MAJU BERSAMA', 'IUP Ekspl.', 'Tembaga', 996.0, 'Aceh Besar', 'No. 540/DPMPTSP/3379/IUP-EKS./2022', '2022-12-30', '2030-12-30'),
  ('PT ADIKARA REKSA MITRA', 'IUP Ekspl.', 'Bijih Besi', 230.0, 'Aceh Besar', 'No. 540/DPMPTSP/1094/IUP-EKS./2025', '2025-01-10', '2030-01-10'),
  ('PT RAIN TAMBANG BERSAUDARA', 'IUP Ekspl.', 'Tembaga', 190.0, 'Aceh Besar', 'No. 540/DPMPTSP/1340/IUP-EKS./2025', '2025-01-10', '2030-01-10'),
  ('PT. SAMANA CITRA AGUNG', 'IUP OP', 'Pasir Besi', 150.0, 'Pidie', 'No. 540/DPMPTSP/3526/IUP-OP2./2020', '2020-11-26', '2030-11-26'),
  ('PT. SERAMBI TIMUR RESOURCES', 'IUP Ekspl.', 'Tembaga', 2537.6, 'Pidie', 'No. 545/DPMPTSP/1349/IUP-EKS./2024', '2024-12-13', '2032-12-13'),
  ('PT. MAGELLANIC GARUDA KENCANA', 'IUP OP', 'Emas (Placer)', 3250.0, 'Aceh Barat', 'No. 191 Tahun 2012', '2012-02-15', '2032-02-15'),
  ('KOPERASI PUTRA PUTRI ACEH', 'IUP OP', 'Emas (Placer)', 195.0, 'Aceh Barat', 'No. 142.A Tahun 2010', '2010-04-21', '2029-04-21'),
  ('PT. AGRABUDI JASA BERSAMA', 'IUP OP', 'Batubara', 5000.0, 'Aceh Barat', 'No. 351 Tahun 2009', '2009-11-23', '2028-03-12'),
  ('PT. MIFA BERSAUDARA', 'IUP OP', 'Batubara', 3134.0, 'Aceh Barat', 'No. 540/DPMPTSP/890/IUP-OP1./2024', '2024-08-08', '2035-04-13'),
  ('PT. PRIMA BARA MAHADANA', 'IUP OP', 'Batubara', 2024.0, 'Aceh Barat', 'No. 545/DPMPTSP/2102/IUP-OP/2017', '2017-08-21', '2032-02-15'),
  ('PT. SURYA MAKMUR INDONESIA', 'IUP OP', 'Batubara', 1600.0, 'Aceh Barat', 'No. 545/DPMPTSP/2564/IUP-OP./2017', '2017-10-20', '2032-10-09'),
  ('PT. INDONESIA PACIFIC ENERGY', 'IUP OP', 'Batubara', 3263.0, 'Aceh Barat', 'No. 545/BP2T/2023/IUP-OP./2016', '2016-10-27', '2036-05-16'),
  ('PT. NIRMALA COAL NUSANTARA', 'IUP OP', 'Batubara', 3198.0, 'Aceh Barat', 'No. 545/DPMPTSP/2571/IUP-OP./2017', '2017-10-23', '2027-10-23'),
  ('PT SURYA BARA MENTARI', 'IUP Ekspl.', 'Batubara', 4327.0, 'Aceh Barat', 'No. 540/DPMPTSP/1187/IUP-EKS./2025', '2025-10-31', '2032-10-31'),
  ('PT SUKSES ENERGI SAKTI', 'IUP Ekspl.', 'Batubara', 4935.0, 'Aceh Barat', 'No. 540/DPMPTSP/22/IUP-EKS./2026', '2026-01-21', '2031-01-21'),
  ('PT. UNIVERSAL PRATAMA SEJAHTERA', 'IUP Ekspl.', 'Batubara', 4934.0, 'Nagan raya', 'No. 545/DPMPTSP/606/IUP-EKS./2021', '2021-03-15', '2028-03-15'),
  ('PT. BARA ENERGI LESTARI', 'IUP OP', 'Batubara', 1495.0, 'Nagan raya', 'No. 545/DPMPTSP/1355/IUP-OP./2017', '2017-06-09', '2027-09-26'),
  ('PT. MEGA MULTI CEMERLANG', 'IUP OP', 'Batubara', 7943.0, 'Nagan raya', 'No. 545/DPMPTSP/1210/IUP-OP./2018', '2018-05-04', '2028-05-03'),
  ('PT. ENERGY TAMBANG GEMILANG', 'IUP OP', 'Batubara', 1180.28, 'Nagan raya', '540/DPMPTSP/602/IUP-OP./2024', '2024-07-02', '2039-07-02'),
  ('CV. BLANG LEUMAK RAYA', 'IUP Ekspl.', 'Emas', 57.0, 'Nagan raya', 'No. 540/DPMPTSP/572/IUP-EKS./2024', '2024-05-13', '2029-05-13'),
  ('PT. HIKMAH BEUTONG RAYA', 'IUP Ekspl.', 'Emas', 595.0, 'Nagan raya', 'No. 540/DPMPTSP/1264/IUP-EKS./2025', '2025-11-17', '2030-11-17'),
  ('PT. ALAM CEMPAKA WANGI', 'IUP Ekspl.', 'Tembaga', 1820.0, 'Nagan Raya', 'No. 540/DPMPTSP/05/IUP-EKS./2026', '2026-01-13', '2031-01-13'),
  ('PT HASIL BUMI SEMBADA', 'IUP Ekspl.', 'Tembaga', 1039.0, 'Nagan Raya', 'No. 540/DPMPTSP/2647/IUP-EKS./2026', '2026-04-22', '2030-04-22'),
  ('PT NAGAN MINERAL MURNI', 'IUP Ekspl.', 'Emas', 543.2, 'Nagan raya', 'No. 540/DPMPTSP/304/IUP-EKS./2026', '2026-05-19', '2031-05-19'),
  ('PT BHUMI KANAKA ARDILAYA', 'IUP Ekspl.', 'Emas', 1805.0, 'Nagan raya', 'No. 540/DPMPTSP/367/IUP-EKS./2026', '2026-06-09', '2031-06-09'),
  ('PT ANDALAS ACEH MINING', 'IUP Ekspl.', 'Emas', 2076.5, 'Nagan raya', 'No. 540/DPMPTSP/526/IUP-EKS./2026', '2026-08-18', '2030-08-18'),
  ('PT. BUMI BABAHROT', 'IUP OP', 'Bijih Besi', 550.0, 'Aceh Barat Daya', '540/DPMPTSP/2640/IUP-OP./2023', '2023-12-22', '2034-03-30'),
  ('PT. JUYA ACEH MINING', 'IUP OP', 'Bijih Besi', 100.0, 'Aceh Barat Daya', 'No. 545/DPMPTSP/1958/IUP-OP./2018', '2018-07-16', '2028-07-16'),
  ('PT. LAUSER KARYA TAMBANG', 'IUP OP', 'Bijih Besi', 98.0, 'Aceh Barat Daya', 'No. 540/DPMPTSP/2137/IUP-OP1./2021', '2021-10-08', '2030-07-26'),
  ('PT. ATHENA TAMBANG JAYA', 'IUP Ekspl.', 'Bijih Besi', 197.0, 'Aceh Barat Daya', 'No. 545/DPMPTSP/589/IUP-EKS./2024', '2024-05-15', '2032-05-15'),
  ('PT ABDYA MINERAL PRIMA', 'IUP Ekspl.', 'Emas', 2319.0, 'Aceh Barat Daya', 'No. 540/DPMPTSP/91/IUP-EKS./2025', '2025-01-17', '2033-01-17'),
  ('KSU TIEGA MANGGIS', 'IUP OP', 'Bijih Besi', 200.0, 'Aceh Selatan', 'No. 540/DPMPTSP/1687/IUP-OP1./2020', '2020-06-11', '2030-06-11'),
  ('PT. SELATAN ACEH EMAS', 'IUP Ekspl.', 'Emas', 1648.0, 'Aceh Selatan', 'No. 545/DPMPTSP/1957/IUP-EKS/2022', '2022-09-15', '2030-09-15'),
  ('PT BERSAMA SUKSES MINING', 'IUP Ekspl.', 'Emas', 752.4, 'Aceh Selatan', 'No. 545/DPMPTSP/882/IUP-EKS/2024', '2024-07-17', '2029-07-17'),
  ('PT. SAMASAMA PRABA DENTA', 'IUP Ekspl.', 'Emas', 605.0, 'Aceh Selatan', 'No. 545/DPMPTSP/158/IUP-EKS/2024', '2024-02-13', '2032-02-13'),
  ('PT. ACSEL MAKMUR ALAM', 'IUP Ekspl.', 'Emas', 577.37, 'Aceh Selatan', 'No. 545/DPMPTSP/408/IUP-EKS/2024', '2024-02-28', '2032-02-28'),
  ('PT. ACEH BUMOE PUSAKA', 'IUP Ekspl.', 'Bijih Besi', 894.6, 'Aceh Selatan', 'No. 545/DPMPTSP/719/IUP-EKS/2024', '2024-07-04', '2032-07-03'),
  ('PT KINSTON ABADI MINERAL', 'IUP Ekspl.', 'Bijih Besi', 4251.3, 'Aceh Selatan', 'No. 545/DPMPTSP/714/IUP-EKS./2025', '2029-10-31', '2033-10-31'),
  ('PT AURUM INDO MINERAL', 'IUP Ekspl.', 'Emas', 1538.5, 'Aceh Selatan', 'No. 545/DPMPTSP/1189/IUP-EKS./2025', '2025-10-31', '2030-10-31'),
  ('PT MINERAL MEGA SENTOSA', 'IUP Ekspl.', 'Emas', 739.0, 'Aceh Selatan', 'No. 540/DPMPTSP/1272/IUP-EKS./2025', '2025-11-19', '2030-11-19'),
  ('PT ACEH PRIMA GEMILANG', 'IUP Ekspl.', 'Bijih Besi', 93.4, 'Aceh Selatan', 'No. 540/DPMPTSP/306/IUP-EKS./2026', '2026-06-22', '2029-06-22'),
  ('PT. ESTAMO MANDIRI', 'IUP OP', 'Bijih Besi', 600.0, 'Subulussalam', 'No. 188.45/084/2011', '2011-10-10', '2033-10-10'),
  ('PT. TAMBANG ALAM BERSAUDARA', 'IUP Ekspl.', 'Bijih Besi', 1355.0, 'Subulussalam', 'No. 545/DPMPTSP/1376/IUP-EKS./2022', '2022-06-16', '2030-06-16'),
  ('PT. SINGKIL BARA UTAMA', 'IUP Ekspl.', 'Batubara', 4614.0, 'Singkil', 'No. 543.5/DPMPTSP/855/IUP-EKS/2024', '2024-07-12', '2031-07-12'),
  ('PT KARYA BUDIDAYA NUSANTARA', 'IUP Ekspl.', 'Batubara', 4792.0, 'Singkil', 'No. 540/DPMPTSP/81/IUP-EKS./2025', '2025-01-14', '2032-01-14'),
  ('PT BRAVO ENERGI SENTOSA', 'IUP Ekspl.', 'Batubara', 3349.0, 'Singkil', 'No. 540/DPMPTSP/82/IUP-EKS./2025', '2025-01-14', '2032-01-14'),
  ('PT ONETAMA KENCANA ENERGI', 'IUP Ekspl.', 'Batubara', 4418.0, 'Singkil', 'No. 540/DPMPTSP/87/IUP-EKS./2025', '2025-01-14', '2032-01-14'),
  ('PT SUMBER ENERGI SANGGABERU', 'IUP Ekspl.', 'Batubara', 4876.0, 'Singkil', 'No. 540/DPMPTSP/95/IUP-EKS./2025', '2025-01-17', '2032-01-17'),
  ('PT SINGKIL KAYA MINERAL', 'IUP Ekspl.', 'Emas', 936.0, 'Singkil', '540/DPMPTSP/320/IUP-EKS./2026', '2026-06-22', '2031-06-22'),
  ('PT ANDALAS ASWINDRA JAYA', 'IUP Ekspl.', 'Emas', 4245.0, 'Singkil', '540/DPMPTSP/318/IUP-EKS./2026', '2026-06-22', '2031-06-22'),
  ('PT PEGASUS MINERAL NUSANTARA', 'IUP OP', 'Emas', 966.0, 'Aceh Tengah', 'No. 540/DPMPTSP/278/IUP-OP./2026', '2026-05-08', '2041-05-05'),
  ('PT DRABA MINERAL INTERNASIONAL', 'IUP Ekspl.', 'Emas', 4569.0, 'Aceh Tengah', 'No. 545/DPMPTSP/1377/IUP-EKS./2022', '2022-06-15', '2030-06-15'),
  ('PT ARUL PEGASING MINERAL', 'IUP Ekspl.', 'Emas', 1047.0, 'Aceh Tengah', 'No. 540/DPMPTSP/528/IUP-EKS./2026', '2026-08-27', '2030-08-27'),
  ('PT PEGASING ALAM MAKMUR', 'IUP Ekspl.', 'Emas', 1015.0, 'Aceh Tengah', 'No. 540/DPMPTSP/510/IUP-EKS./2026', '2026-09-01', '2030-09-01'),
  ('PT RINDANG JAYA RESOURCES', 'IUP Ekspl.', 'Bijih Besi', 85.6, 'Gayo Lues', 'No. 545/DPMPTSP/1124/IUP-EKS./2022', '2022-05-11', '2027-05-11'),
  ('PT ARITA ACEH SEJAHTERA', 'IUP Ekspl.', 'Galena', 46.0, 'Aceh Jaya', 'No. 540/DPMPTSP/1292/IUP-EKS./2022', '2022-05-30', '2027-05-30'),
  ('PT MAS PUTIH ANEKA TAMBANG', 'IUP Ekspl.', 'Batubara', 4949.0, 'Aceh Jaya', 'No. 545/DPMPTSP/1580/IUP-EKS./2022', '2022-07-13', '2029-07-13'),
  ('PT LONGSUNINDO PERKASA', 'IUP Ekspl.', 'Batubara', 4655.0, 'Aceh Jaya', 'No. 540/DPMPTSP/1732/IUP-EKS./2022', '2022-08-15', '2029-08-15'),
  ('PT MINERAL AGAM PRIMA', 'IUP Ekspl.', 'Bijih Besi', 1390.0, 'Aceh Jaya', 'No. 545/DPMPTSP/1908/IUP-EKS./2022', '2022-09-08', '2030-09-08'),
  ('PT ACEH JAYA ANDALAN NUSANTARA', 'IUP Ekspl.', 'Galena', 4917.0, 'Aceh Jaya', 'No. 545/DPMPTSP/377/IUP-EKS./2024', '2024-02-22', '2032-02-22'),
  ('PT ACEH JAYA ALAM MINERAL', 'IUP Ekspl.', 'Emas', 4877.0, 'Aceh Jaya', 'No. 545/DPMPTSP/428/IUP-EKS./2024', '2024-03-05', '2032-03-05'),
  ('PT ALEXA TAMBANG ABADI', 'IUP Ekspl.', 'Emas', 1826.5, 'Aceh Jaya', 'No. 545/DPMPTSP/600/IUP-EKS./2024', '2024-07-04', '2032-07-03'),
  ('PT ACEH JAYA BARU UTAMA', 'IUP Ekspl.', 'Emas', 2362.0, 'Aceh Jaya', 'No. 540/DPMPTSP/90/IUP-EKS./2025', '2025-01-17', '2033-01-17'),
  ('PT BUMI MULYA ENERGI', 'IUP Ekspl.', 'Emas', 1787.0, 'Aceh Jaya', 'No. 540/DPMPTSP/1188/IUP-EKS./2025', '2025-10-31', '2033-10-31'),
  ('PT SUMBER BERKAH ENERGI', 'IUP Ekspl.', 'Emas', 1568.0, 'Aceh Jaya', 'No. 540/DPMPTSP/1270/IUP-EKS./2025', '2025-11-18', '2030-11-18'),
  ('PT BUKIT MINERAL ABADI', 'IUP Ekspl.', 'Emas', 1426.0, 'Aceh Jaya', 'No. 540/DPMPTSP/196/IUP-EKS./2026', '2026-03-30', '2030-03-30'),
  ('PT WAHANA PRIMA INVESTINDO', 'IUP Ekspl.', 'Emas', 3678.2, 'Aceh Jaya', 'No. 540/DPMPTSP/193/IUP-EKS./2026', '2026-03-30', '2030-03-30'),
  ('PT BERKAH BERSAMA MINERAL', 'IUP Ekspl.', 'Emas', 1261.0, 'Aceh Jaya', 'No. 540/DPMPTSP/319/IUP-EKS./2026', '2026-06-22', '2031-06-22'),
  ('PT PUTRA BOMBANA BUANA', 'IUP Ekspl.', 'Emas', 3533.0, 'Aceh Jaya', 'No. 540/DPMPTSP/428/IUP-EKS./2026', '2026-08-27', '2031-08-27'),
  ('PT MAHAKARYA BAJA ABADI', 'IUP Ekspl.', 'Emas', 1112.0, 'Aceh Jaya', 'No. 540/DPMPTSP/509/IUP-EKS./2026', '2026-08-27', '2030-08-27')
)
INSERT INTO public.iup (nama, status_iup, komoditas, luas_ha, lokasi, nomor_sk, tgl_mulai, tgl_berakhir)
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
