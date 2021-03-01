# cfr_bar_parser
Un parser pentru Buletinele de Avizare Restrictii CFR

# Requirements

1. `R` versiunea `3.6+` sau mai mult (rulat pe `4.0.3`).
2. `LibreOffice` instalat in asa fel incat comanda `soffice` sa fie disponibila in `$PATH`. Motorul `LibreOffice` e chemat pentru un singur lucru, sa converteasca `doc` in `docx`. Pe un sistem `Linux`, daca aveti LibreOffice, e disponbil automat; daca nu, folositi managerul dvs. de pachete (ex. `apt-get install libreoffice` pe sisteme Debian/Ubuntu). Pe `MacOS`, folositi managerul de pachete [Homebrew](https://brew.sh/): `brew install --cask libreoffice`. Pe Windows, ar trebui sa functioneze cat timp puteti expune comanda soffice in `PATH`. Alternativ, puteti folosi `Windows Subsystem for Linux` pe care sa instalati `R`, `curl` si `LibreOffice`.
3. `curl`, orice versiune.

# Instalare

Nu necesita vreo forma de instalare.

# Rulare

- Tot ce trebuie sa faceti este sa rulati `Rscript CFR_BAR_extract.r`. Alternativ, daca doriti rulare interactiva, un notebook `Jupyt
- La prima rulare, `R` isi va instala dependintele folosind managerul de pachete intern si arhiva `CRAN`. Este posibil sa vi se solicite sa selectati un server de download: alegeti oricare server. Instalarea dependintelor poate dura cateva minute, si va afisa foarte mult output. Se va intampla doar la prima rulare.
- Scriptul este relativ lent. Conversia `DOC` in `DOCX` dureaza undeva la 1-1.5 minute (`soffice` este lent). Citirea si parsarea documentului de catre `R` dureaza, mai apoi, cateva minute (`R` este lent). Nu opriti rularea, merge.
- Scriptul va da `warning` acolo unde intalneste un caz neimplementat, cel mai comun (adica in 4 locuri in tot BAR-ul) fiind `firul III`, pe care-l umple cu NA-uri pentru ca CFR foloseste o forma de tabel incompatibila. Mesajul `NAs introduced by coercion` se poate ignora fara probleme.
- Scriptul va produce trei fisiere : `bar_extras.csv` si `bar_extras.json` cu datele parsate si `bar.docx` care este BAR-ul brut.

# Note

As said, este **lent**, dar cum trebuie sa ruleze de 3/luna, este ok. Parserul R de docx este foarte lent, si single core, si nu se poate prespecifica ce sa parseze, pentru ca tot documentul este esential. soffice e foarte lent la conversie si el. Pe sistemul meu, BAR Bucuresti e parsat in 6 min : 13 sec.63 dar YMMV (sistemul nu ar trebui sa conteze; a fost rulat pe un OSX cu 32 GB RAM si i9, dar e single-core si a folosit <400 MB RAM).  

BAR-urile par editate manual de CFR. Desi exista cateva "fallbacks" implementate, pot aparea anumite probleme neprevazute care sa duca la crash. Faceti un issue sau anuntati pe forum. 

# TODO

- Facut sa descarce toate cele 8 BAR-uri si sa faca un singur mare document cu toate magistralele si liniile secundare. [EASY]
- O `functie lambda` pe AWS, care sa porneasca afacerea pe 1,11 si 21 ale fiecarei luni. _Cand am timp, adica niciodata. Daca vreti voi..._
