DROP TABLE IF EXISTS tree;
CREATE TABLE tree (
      id  int primary key
    , pid int
    , val int
);

-- OFFSET下标也是从0开始
INSERT INTO tree VALUES (0, -1, -1), (1, 0, 1), (2, 0, 2), (3, 1, 4), (4, 1, 5), (5, 2, 7), (6, 2, 8);

SELECT * FROM tree WHERE id != 0 ORDER BY id DESC LIMIT 2 OFFSET 4;
SELECT pid, sum(val) FROM tree GROUP BY pid HAVING sum(val) > 0 ORDER BY sum(val);

WITH RECURSIVE subtree AS (
    SELECT * FROM tree WHERE id = 1
    UNION
    SELECT rt.* from tree rt INNER JOIN subtree st ON rt.pid = st.id
)
SELECT * FROM subtree;
