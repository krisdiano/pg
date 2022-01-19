DROP TYPE IF EXISTS test.student;
DROP TYPE IF EXISTS test.mood;
CREATE TYPE test.student AS (
      name text
    , age  int   
);
CREATE TYPE test.mood AS ENUM ('sad', 'ok', 'happy');

DROP TABLE IF EXISTS test.demo;
CREATE TABLE test.demo (
      id   int
    , stu  test.student
    , mood test.mood
);

DROP TABLE IF EXISTS test.log;
CREATE TABLE test.log (
      opt text PRIMARY KEY
    , cnt int
);

CREATE OR REPLACE FUNCTION record() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO test.log VALUES (TG_OP, 1) ON CONFLICT(opt) DO UPDATE SET cnt = log.cnt + 1;
    IF (TG_OP <> 'DELETE') THEN
        RETURN NEW;
    ENDIF;
    RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_trigger AFTER INSERT OR UPDATE
ON test.demo
FOR EACH ROW EXECUTE FUNCTION record(); 

INSERT INTO test.demo VALUES (1, '("ltx1", 20)', 'ok');
-- 没有数据则对应的值为NULL
INSERT INTO test.demo VALUES (2, '(, 20)', 'ok');
-- 空字符串不等价于NULL
INSERT INTO test.demo VALUES (3, '("", 22)', 'ok');

-- ROW比字符串表示更友好
INSERT INTO test.demo VALUES (4, ROW('ltx4', 23), 'happy');
-- ROW关键字可以省略
INSERT INTO test.demo VALUES (5, ('ltx5', 23), 'happy');


-- 因为复合成员的访问struct.field类似于schema.table
-- 因此在可能出现schema.table的位置使用struct.field
-- 需要使用(struct).field的形式
UPDATE test.demo SET stu.age = (stu).age + 1 where (stu).age = 20 AND (stu).name IS NULL;
UPDATE test.demo SET stu = ('ltx3', 23) where id = 3;
