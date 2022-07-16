
CREATE TABLE TABLE_1 (ID BIGSERIAL PRIMARY KEY, NUMBERS int);
DO $$
DECLARE variable integer := 1;
BEGIN
WHILE variable <= 5000000 LOOP
INSERT INTO TABLE_1 (NUMBERS) VALUES (Cast(random()*(-1000000-1000000)+1000000 as int));
variable := variable + 1;
END LOOP;
COMMIT;
Copy (SELECT series
FROM generate_series(-1000000, 1000000, 1) series
LEFT JOIN TABLE_1 ON series = TABLE_1.numbers
WHERE numbers IS null) To '/tmp/result.csv' With CSV DELIMITER ',' HEADER;
END $$;

