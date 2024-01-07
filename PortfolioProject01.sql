--Lista miast (bez powt�rze?), wyst?puj?ca w adresach klient�w z USA lub dostawc�w nie z Niemiec.
--Dane wy?wietli? w kolejno?ci alfabetycznej, z pomini?ciem warto?ci pustych.
SELECT Miasto, 'k' [Kod]
FROM Klienci
	UNION 
SELECT Miasto, 'd' [Kod]
FROM Dostawcy

--Lista wszystkich nazw kraj�w wyst?puj?cych w adresach tych klient�w i dostawc�w, kt�rych nazwy firm s? nie kr�tsze
--ni? 30 znak�w. Dane wy?wietli? w kolejno?ci alfabetycznej.
SELECT Kraj, 'k' [Kod]
FROM Klienci
WHERE LEN(NazwaFirmy) >=30
	UNION
SELECT Kraj, 'd' [Kod]
FROM Dostawcy
WHERE LEN(NazwaFirmy) >=30
ORDER BY Kraj ASC

--Sprawdzi?, kt�re miasta wyst?puj? zar�wno na li?cie adresowej klient�w, jak i w adresach dostawc�w.
SELECT Miasto
FROM Klienci
	INTERSECT
SELECT Miasto
FROM Dostawcy

--Sprawdzi?, kt�re miasta wyst?puj? w adresach pracownik�w, ale nie ma ich w?r�d adres�w dostawc�w.
SELECT Miasto, 'p'
FROM Pracownicy
	EXCEPT
SELECT Miasto, 'd'
FROM Dostawcy

--Lista zam�wie? produkt�w wys?anych w czerwcu 1997 roku. Dane w formacie: Nr zam�wienia, Data (rrrr-mm-dd), Nazwa produktu, Nazwa klienta (kraj odbiorcy).
--Dane posortowa? rosn?co wg. daty wysy?ki.
SELECT z.IDzam�wienia [Nr zam�wienia], CAST(DataZam�wienia AS date) [Data], p.NazwaProduktu, k.NazwaFirmy +' ( '+z.KrajOdbiorcy +' ) '
FROM Zam�wienia z JOIN Klienci k ON z.IDklienta = k.IDklienta
				  JOIN PozycjeZam�wienia pz ON pz.IDzam�wienia = z.IDzam�wienia
				  JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
WHERE z.DataZam�wienia BETWEEN '20080901' AND '20080930'
ORDER BY [Data]
 --Przygotowa? dane do faktur dla klient�w z Niemiec, od kt�rych zam�wienia przyjmowa?a wy??cznie Anne Dodsworth. 
 --Dane wynikowe (bez powt�rze?), w formacie: Nr faktury (IDZam�wienia), Data zam�wienia (rrrr-mm-dd), Klient (nazwa firmy), Miejscowo??, Adres, Pracownik (imi? i nazwisko).
 --Dane posortowa? alfabetycznie wg. nazw firm.
SELECT z.IDzam�wienia [Numer Faktury], CAST(z.DataZam�wienia AS date) [Data Zam�wienia], k.NazwaFirmy [Klient], k.Miasto,k.Adres, p.Imi?,p.Nazwisko
FROM Zam�wienia z JOIN Pracownicy p ON z.IDpracownika = p.IDpracownika
				  JOIN Klienci k ON z.IDklienta = k.IDklienta
WHERE k.Kraj = 'Niemcy' AND p.Nazwisko = 'Dodsworth'
ORDER BY k.NazwaFirmy

 --Ile kategorii produkt�w by?o zamawianych w poszczeg�lnych dniach pierwszego tygodnia lutego 1997 roku?
 SELECT DAY(z.DataZam�wienia), COUNT(DISTINCT p.IDkategorii) [Ilo?c Kategorii]
 FROM Zam�wienia z JOIN PozycjeZam�wienia pz ON z.IDzam�wienia = pz.IDzam�wienia
				   JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
WHERE YEAR(z.DataZam�wienia) = 2009 AND MONTH(z.DataZam�wienia)= 2 AND DAY(z.DataZam�wienia) BETWEEN 1 AND 7
GROUP BY DAY(z.DataZam�wienia)
--Poda? liczb? wszystkich zam�wie? przyj?tych w 1996 od klient�w z USA, na kt�rych wyst?powa?y produkty z kategorii 'Przyprawy'.
SELECT COUNT(z.IDzam�wienia) [Liczba Zam�wie?]
FROM Zam�wienia z JOIN PozycjeZam�wienia pz ON z.IDzam�wienia = pz.IDzam�wienia
				  JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
				  JOIN Kategorie k ON k.IDkategorii = p.IDkategorii
WHERE YEAR(z.DataZam�wienia) = 2010 AND z.KrajOdbiorcy = 'USA' AND k.NazwaKategorii = 'Przyprawy'

--Opracowa? zapytanie w formacie: Nazwa, Opis informacji agregowanej, Warto?? agregowana, zestawiaj?ce w kolejnych liniach:
--    - linia 1: nazwa firmy, kt�ra z?o?y?a najwi?cej zam�wie?, 'liczba zam�wie?', warto??
--    - linia 2: nazwa kategorii, kt�ra ma przypisanych najwi?cej produkt�w, 'liczba produkt�w', warto??
--    - linia 3: nazwa produktu o najwy?szej ??cznej kwocie sprzeda?y, 'top produkt', kwota
--    - linia 4: imi? i nazwisko pracownika, kt�ry przyj?? najwi?cej zam�wie?, 'liczba zam�wie?', warto??.

SELECT 'Firma: ' + wa1.Firma [Nazwa], wa1.[Opis inf. agregowanej], wa1.[Warto?? Agregowana]
FROM (SELECT TOP(1) k.NazwaFirmy [Firma],
	  'Liczba Zam�wie?' [Opis inf. agregowanej],
	  COUNT(z.IDzam�wienia) [Warto?? Agregowana]
		FROM Zam�wienia z JOIN Klienci k ON z.IDklienta = k.IDklienta
		GROUP BY k.NazwaFirmy
		ORDER BY COUNT(z.IDzam�wienia) DESC) wa1

	UNION

SELECT 'Kategoria: ' + wa2.Kategoria [Nazwa], wa2.[Opis inf. agregowanej],wa2.[Warto?? Agregowana]
FROM (SELECT TOP (1) 
	  k.NazwaKategorii [Kategoria],
	  'Liczba produkt�w w kategorii'[Opis inf. agregowanej],
	  COUNT(p.IDkategorii) [Warto?? Agregowana]
	  FROM Produkty p JOIN Kategorie k ON p.IDkategorii = k.IDkategorii
	  GROUP BY k.NazwaKategorii
	  ORDER BY [Warto?? Agregowana]DESC) wa2

	UNION

SELECT 'Nazwa Produktu: '+ wa3.Produkt [Nazwa],wa3.[Opis inf. agregowanej], wa3.[Warto?? Agregowana]
FROM (SELECT TOP (1) p.NazwaProduktu [Produkt],
	  'Produkt o najwy?szej ??cznej kwocie sprzeda?y'[Opis inf. agregowanej],
	  SUM(pz.CenaJednostkowa*Ilo??) [Warto?? Agregowana]
	  FROM Zam�wienia z JOIN PozycjeZam�wienia pz ON z.IDzam�wienia = pz.IDzam�wienia
						JOIN Produkty p ON p.IDproduktu = pz.IDproduktu
	  GROUP BY p.NazwaProduktu
	  ORDER BY SUM(pz.CenaJednostkowa*Ilo??) DESC) wa3

	UNION
	--    - linia 4: imi? i nazwisko pracownika, kt�ry przyj?? najwi?cej zam�wie?, 'liczba zam�wie?', warto??.
SELECT 'Pracowanik: ' + wa4.Pracownik [Nazwa], wa4.[Opis inf. agregowanej], ROUND(wa4.[Warto?? Agregowana],0)
FROM (SELECT TOP(1) p.Imi? +' '+UPPER(p.Nazwisko) [Pracownik],
	  'Najlepszy Pracownik' [Opis inf. agregowanej],
	  CAST(COUNT(DISTINCT z.IDzam�wienia) AS nvarchar) [Warto?? Agregowana]
	  FROM Zam�wienia z JOIN Pracownicy p ON p.IDpracownika = z.IDpracownika
	  GROUP BY p.Imi?, p.Nazwisko
	  ORDER BY COUNT(DISTINCT z.IDzam�wienia)DESC) wa4


--zadania utrwalaj?ce umiej?tno?? tworzenia zapyta? z filtrowaniem zbior�w (z u?yciem klauzul WHERE i HAVING)
--P04.01 - Wy?wietli? numery zam�wie? zawieraj?cych przynajmniej 5 pozycji,
--kt�rych ??czna warto?? zam�wienia jest z przedzia?u [700, 1750] PLN. Dane wy?wietli? w formacie: Nr zam�wienia, Liczba pozycji, Warto?? zam�wienia.
--Dane posortowa? malej?co wg. kolumny  Warto?? zam�wienia.

SELECT z.IDzam�wienia, COUNT(pz.IDproduktu) [Liczba Pozycji], SUM(pz.CenaJednostkowa * pz.Ilo??) [Warto?? Zam�wienia]
FROM Zam�wienia z JOIN PozycjeZam�wienia pz ON z.IDzam�wienia = pz.IDzam�wienia
GROUP BY z.IDzam�wienia
HAVING COUNT(pz.IDproduktu) >= 5 AND SUM(pz.CenaJednostkowa * pz.Ilo??) BETWEEN 700 AND 1750
ORDER BY [Warto?? Zam�wienia] ASC
          
SELECT k.IDklienta, COUNT(z.IDzam�wienia) [Liczba Zam�wie?], SUM(pz.Ilo??) [Liczba Sztuk]
FROM Zam�wienia z JOIN PozycjeZam�wienia pz ON z.IDzam�wienia = pz.IDzam�wienia
				  JOIN Klienci k ON k.IDklienta = z.IDklienta
WHERE YEAR(z.DataZam�wienia) = 2015
GROUP BY k.IDklienta
HAVING COUNT(z.IDzam�wienia) >=10 AND SUM(pz.Ilo??) > 100
ORDER BY [Liczba Zam�wie?] DESC, [Liczba Sztuk] DESC

