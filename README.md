# Start-up instructions and description of functions

## Task number 2 - database administration

>Wykorzystując serwer PostgreSQL (w kontenerze), utwórz bazę, schemat i tabelę. Tabela w strukturze ma przechowywać liczbę całkowitą. Należy umieścić w tabeli 5 mln rekordów z wartością pseudolosową z przedziału od -1000000 do +1000000. Przygotuj procedurę badającą czy w wygenerowanych danych znajdują się wszystkie liczby z podanego wcześniej przedziału (tj. badanie luk).

### 1. File named init.sql contains instructions for creating and filling table with data

* *Create table (TABLE_1) with two columns ID and NUMBERS*

```SQL
CREATE TABLE TABLE_1 (ID BIGSERIAL PRIMARY KEY, NUMBERS int);
```

* *Execute code block with variable declaration and start loop to fill columns according to the content of the task.*
* *Loop condition setup for 5 million records.*
* *Randomizing numbers <-1000000, 1000000> using cast(random()) function.*
* *Auto increment of the variable by 1.*
* *End of loop.*

```SQL
DO $$
DECLARE variable integer := 1;
BEGIN
WHILE variable <= 5000000 LOOP
INSERT INTO TABLE_1 (NUMBERS) VALUES (Cast(random()*(-1000000-1000000)+1000000 as int));
variable := variable + 1;
END LOOP;
```

* *Make changes permanent.*

```SQL
COMMIT;
```

* __*Gaps finding-*__ *genering column with full range <-1000000, 1000000> and then LEFT JOIN to the NUMBERS columnt from TABLE_1*
* *Final result showing the missing numbers in the range is copied to the file '/tmp/result.csv'*

```SQL
Copy (SELECT series
FROM generate_series(-1000000, 1000000, 1) series
LEFT JOIN TABLE_1 ON series = TABLE_1.numbers
WHERE numbers IS null) To '/tmp/result.csv' With CSV DELIMITER ',' HEADER;
END $$;
```

### 2. DockerFile contains a recipe to create Image

* *Setting the database name, username, password and port*
* *Adding file with solution init.sql to Image.*

```dockerfile
FROM postgres
ENV POSTGRES_DB=test_database
ENV POSTGRES_USER=test
ENV POSTGRES_PASSWORD=test
EXPOSE 5432:5432
ADD ./init.sql /docker-entrypoint-initdb.d/
CMD ["postgres"]
```

* *Use PowerShell to build Image.*

```powershell
$docker build --pull --rm -f "DockerFile" -t posthgre:latest "."
```

* *Then run Container using created Image.*

```powershell
$docker run --name posthgre -d posthgre
```

* *To get into the contaioner and find result of gap finding use commends below.*
* *Command 'cat result.csv' shows list of missing numbers.*

```powershell
$docker exec -it posthgre bash
root@9e70b05588d6:/# ls
bin   dev                         etc   lib    media  opt   root  sbin  sys  usr
boot  docker-entrypoint-initdb.d  home  lib64  mnt    proc  run   srv   tmp  var
root@9e70b05588d6:/# cd tmp
root@9e70b05588d6:/tmp# ls
result.csv
root@9e70b05588d6:/tmp# cat resul.csv
```
