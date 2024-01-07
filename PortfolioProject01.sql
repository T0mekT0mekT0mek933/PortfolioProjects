--Lista miast (bez powtórze?), wyst?puj?ca w adresach klientów z USA lub dostawców nie z Niemiec.
--Dane wy?wietli? w kolejno?ci alfabetycznej, z pomini?ciem warto?ci pustych.
SELECT Miasto, 'k' [Kod]
FROM Klienci
	UNION 
SELECT Miasto, 'd' [Kod]
FROM Dostawcy

--Lista wszystkich nazw krajów wyst?puj?cych w adresach tych klientów i dostawców, których nazwy firm s? nie krótsze
--ni? 30 znaków. Dane wy?wietli? w kolejno?ci alfabetycznej.
SELECT Kraj, 'k' [Kod]
FROM Klienci
WHERE LEN(NazwaFirmy) >=30
	UNION
SELECT Kraj, 'd' [Kod]
FROM Dostawcy
WHERE LEN(NazwaFirmy) >=30
ORDER BY Kraj ASC

--Sprawdzi?, które miasta wyst?puj? zarówno na li?cie adresowej klientów, jak i w adresach dostawców.
SELECT Miasto
FROM Klienci
	INTERSECT
SELECT Miasto
FROM Dostawcy

--Sprawdzi?, które miasta wyst?puj? w adresach pracowników, ale nie ma ich w?ród adresów dostawców.
SELECT Miasto, 'p'
FROM Pracownicy
	EXCEPT
SELECT Miasto, 'd'
FROM Dostawcy

--Lista zamówie? produktów wys?anych w czerwcu 1997 roku. Dane w formacie: Nr zamówienia, Data (rrrr-mm-dd), Nazwa produktu, Nazwa klienta (kraj odbiorcy).
--Dane posortowa? rosn?co wg. daty wysy?ki.
SELECT z.IDzamówienia [Nr zamówienia], CAST(DataZamówienia AS date) [Data], p.NazwaProduktu, k.NazwaFirmy +' ( '+z.KrajOdbiorcy +' ) '
FROM Zamówienia z JOIN Klienci k ON z.IDklienta = k.IDklienta
				  JOIN PozycjeZamówienia pz ON pz.IDzamówienia = z.IDzamówienia
				  JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
WHERE z.DataZamówienia BETWEEN '20080901' AND '20080930'
ORDER BY [Data]
 --Przygotowa? dane do faktur dla klientów z Niemiec, od których zamówienia przyjmowa?a wy??cznie Anne Dodsworth. 
 --Dane wynikowe (bez powtórze?), w formacie: Nr faktury (IDZamówienia), Data zamówienia (rrrr-mm-dd), Klient (nazwa firmy), Miejscowo??, Adres, Pracownik (imi? i nazwisko).
 --Dane posortowa? alfabetycznie wg. nazw firm.
SELECT z.IDzamówienia [Numer Faktury], CAST(z.DataZamówienia AS date) [Data Zamówienia], k.NazwaFirmy [Klient], k.Miasto,k.Adres, p.Imi?,p.Nazwisko
FROM Zamówienia z JOIN Pracownicy p ON z.IDpracownika = p.IDpracownika
				  JOIN Klienci k ON z.IDklienta = k.IDklienta
WHERE k.Kraj = 'Niemcy' AND p.Nazwisko = 'Dodsworth'
ORDER BY k.NazwaFirmy

 --Ile kategorii produktów by?o zamawianych w poszczególnych dniach pierwszego tygodnia lutego 1997 roku?
 SELECT DAY(z.DataZamówienia), COUNT(DISTINCT p.IDkategorii) [Ilo?c Kategorii]
 FROM Zamówienia z JOIN PozycjeZamówienia pz ON z.IDzamówienia = pz.IDzamówienia
				   JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
WHERE YEAR(z.DataZamówienia) = 2009 AND MONTH(z.DataZamówienia)= 2 AND DAY(z.DataZamówienia) BETWEEN 1 AND 7
GROUP BY DAY(z.DataZamówienia)
--Poda? liczb? wszystkich zamówie? przyj?tych w 1996 od klientów z USA, na których wyst?powa?y produkty z kategorii 'Przyprawy'.
SELECT COUNT(z.IDzamówienia) [Liczba Zamówie?]
FROM Zamówienia z JOIN PozycjeZamówienia pz ON z.IDzamówienia = pz.IDzamówienia
				  JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
				  JOIN Kategorie k ON k.IDkategorii = p.IDkategorii
WHERE YEAR(z.DataZamówienia) = 2010 AND z.KrajOdbiorcy = 'USA' AND k.NazwaKategorii = 'Przyprawy'

--Opracowa? zapytanie w formacie: Nazwa, Opis informacji agregowanej, Warto?? agregowana, zestawiaj?ce w kolejnych liniach:
--    - linia 1: nazwa firmy, która z?o?y?a najwi?cej zamówie?, 'liczba zamówie?', warto??
--    - linia 2: nazwa kategorii, która ma przypisanych najwi?cej produktów, 'liczba produktów', warto??
--    - linia 3: nazwa produktu o najwy?szej ??cznej kwocie sprzeda?y, 'top produkt', kwota
--    - linia 4: imi? i nazwisko pracownika, który przyj?? najwi?cej zamówie?, 'liczba zamówie?', warto??.

SELECT 'Firma: ' + wa1.Firma [Nazwa], wa1.[Opis inf. agregowanej], wa1.[Warto?? Agregowana]
FROM (SELECT TOP(1) k.NazwaFirmy [Firma],
	  'Liczba Zamówie?' [Opis inf. agregowanej],
	  COUNT(z.IDzamówienia) [Warto?? Agregowana]
		FROM Zamówienia z JOIN Klienci k ON z.IDklienta = k.IDklienta
		GROUP BY k.NazwaFirmy
		ORDER BY COUNT(z.IDzamówienia) DESC) wa1

	UNION

SELECT 'Kategoria: ' + wa2.Kategoria [Nazwa], wa2.[Opis inf. agregowanej],wa2.[Warto?? Agregowana]
FROM (SELECT TOP (1) 
	  k.NazwaKategorii [Kategoria],
	  'Liczba produktów w kategorii'[Opis inf. agregowanej],
	  COUNT(p.IDkategorii) [Warto?? Agregowana]
	  FROM Produkty p JOIN Kategorie k ON p.IDkategorii = k.IDkategorii
	  GROUP BY k.NazwaKategorii
	  ORDER BY [Warto?? Agregowana]DESC) wa2

	UNION

SELECT 'Nazwa Produktu: '+ wa3.Produkt [Nazwa],wa3.[Opis inf. agregowanej], wa3.[Warto?? Agregowana]
FROM (SELECT TOP (1) p.NazwaProduktu [Produkt],
	  'Produkt o najwy?szej ??cznej kwocie sprzeda?y'[Opis inf. agregowanej],
	  SUM(pz.CenaJednostkowa*Ilo??) [Warto?? Agregowana]
	  FROM Zamówienia z JOIN PozycjeZamówienia pz ON z.IDzamówienia = pz.IDzamówienia
						JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
	  GROUP BY p.NazwaProduktu
	  ORDER BY SUM(pz.CenaJednostkowa*Ilo??) DESC) wa3

	UNION
	--    - linia 4: imi? i nazwisko pracownika, który przyj?? najwi?cej zamówie?, 'liczba zamówie?', warto??.
SELECT 'Pracowanik: ' + wa4.Pracownik [Nazwa], wa4.[Opis inf. agregowanej], ROUND(wa4.[Warto?? Agregowana],0)
FROM (SELECT TOP(1) p.Imi? +' '+UPPER(p.Nazwisko) [Pracownik],
	  'Najlepszy Pracownik' [Opis inf. agregowanej],
	  CAST(COUNT(DISTINCT z.IDzamówienia) AS nvarchar) [Warto?? Agregowana]
	  FROM Zamówienia z JOIN Pracownicy p ON p.IDpracownika = z.IDpracownika
	  GROUP BY p.Imi?, p.Nazwisko
	  ORDER BY COUNT(DISTINCT z.IDzamówienia)DESC) wa4


--zadania utrwalaj?ce umiej?tno?? tworzenia zapyta? z filtrowaniem zbiorów (z u?yciem klauzul WHERE i HAVING)
--P04.01 - Wy?wietli? numery zamówie? zawieraj?cych przynajmniej 5 pozycji,
--których ??czna warto?? zamówienia jest z przedzia?u [700, 1750] PLN. Dane wy?wietli? w formacie: Nr zamówienia, Liczba pozycji, Warto?? zamówienia.
--Dane posortowa? malej?co wg. kolumny  Warto?? zamówienia.

SELECT z.IDzamówienia, COUNT(pz.IDproduktu) [Liczba Pozycji], SUM(pz.CenaJednostkowa * pz.Ilo??) [Warto?? Zamówienia]
FROM Zamówienia z JOIN PozycjeZamówienia pz ON z.IDzamówienia = pz.IDzamówienia
GROUP BY z.IDzamówienia
HAVING COUNT(pz.IDproduktu) >= 5 AND SUM(pz.CenaJednostkowa * pz.Ilo??) BETWEEN 700 AND 1750
ORDER BY [Warto?? Zamówienia] ASC
          
SELECT k.IDklienta, COUNT(z.IDzamówienia) [Liczba Zamówie?], SUM(pz.Ilo??) [Liczba Sztuk]
FROM Zamówienia z JOIN PozycjeZamówienia pz ON z.IDzamówienia = pz.IDzamówienia
				  JOIN Klienci k ON k.IDklienta = z.IDklienta
WHERE YEAR(z.DataZamówienia) = 2015
GROUP BY k.IDklienta
HAVING COUNT(z.IDzamówienia) >=10 AND SUM(pz.Ilo??) > 100
ORDER BY [Liczba Zamówie?] DESC, [Liczba Sztuk] DESC

