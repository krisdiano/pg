-- 变量声明
-- 引用匿名输入输出参数
CREATE OR REPLACE FUNCTION mul5and10(old real, OUT m5 real, OUT m10 real) AS $$
DECLARE
    base5 real := 5.0;
    base real NOT NULL := 10.0;
BEGIN
    m5 = old * base5;
    m10 = old * base10;
END;
$$ LANGUAGE plpgsql;

-- 使用命名入参和RETURNS声明返回值
-- RETURNS为多态类型，会自动创建一个$0变量，类型是根据输入自动推导的返回值类型
-- ALIAS进行变量重命名
CREATE OR REPLACE FUNCTION add_three_values(v1 anyelement, v2 anyelement, v3 anyelement)
RETURNS anyelement AS $$
DECLARE
    result ALIAS FOR $0;
BEGIN
    result := v1 + v2 + v3;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 复制类型 variable%TYPE
CREATE OR REPLACE FUNCTION get_schema_with_direct() RETURNS text AS $$
DECLARE
    tmp pg_namespace.nspname%TYPE;
BEGIN
    SELECT nspname INTO tmp FROM pg_namespace limit 1;
    RETURN tmp;
END
$$ LANGUAGE plpgsql;

-- 行类型 table%ROWTYPE
CREATE OR REPLACE FUNCTION get_schema_with_row() RETURNS text AS $$
DECLARE
    tmp pg_namespace%ROWTYPE;
BEGIN
    SELECT * INTO tmp FROM pg_namespace limit 1;
    RETURN tmp.nspname;
END
$$ LANGUAGE plpgsql;

-- 记录类型 name RECORD
CREATE OR REPLACE FUNCTION get_schema_with_record() RETURNS text AS $$
DECLARE
    tmp RECORD;
BEGIN
    SELECT * INTO tmp FROM pg_namespace limit 1;
    RETURN tmp.nspname;
END
$$ LANGUAGE plpgsql;

-- 表达式和sql查询没有变量接受会报错，可以使PERFORM query忽略结果
-- 用法是将PERFROM替换SELECT就可以忽略
CREATE OR REPLACE FUNCTION perform() RETURNS text AS $$
BEGIN
    PERFORM * FROM pg_namespace;
    RETURN 'perform execed';
END
$$ LANGUAGE plpgsql;

-- 单一行结果赋值
-- SELECT select_expressions INTO [STRICT] target FROM ...;
-- INSERT ... RETURNING expressions INTO [STRICT] target;
-- UPDATE ... RETURNING expressions INTO [STRICT] target;
-- DELETE ... RETURNING expressions INTO [STRICT] target;

-- 行类型的简写 table%ROWTYPE => table
CREATE OR REPLACE FUNCTION get_schema_with_name(name text) RETURNS pg_namespace AS $$
DECLARE
    tmp pg_namespace%ROWTYPE;
BEGIN
    SELECT * INTO tmp FROM pg_namespace WHERE nspname = name;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'nspname % not found', name;
    END IF;

    -- 指定了STRICT那么结果要么只有一行要么报告一个运行时异常
    -- 对于带有RETURNING的INSERT,UPDATE和DELETE来说不指定也是STRICT模式
    SELECT * INTO STRICT tmp FROM pg_namespace WHERE nspname = name;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'nspname % not found', name;
    WHEN TOO_MANY_ROWS THEN
        RAISE EXCEPTION 'nspname % not unique', name;
END
$$ LANGUAGE plpgsql;

-- 返回多行
-- 多行中的返回
CREATE OR REPLACE FUNCTION get_all_databases() RETURNS SETOF pg_database AS $$
DECLARE
    tmp pg_database;
    cnt int = 0;
BEGIN
    SELECT count(*) INTO cnt FROM pg_database;
    FOR i IN 1..cnt LOOP
        IF i = 1 THEN
            SELECT * INTO tmp FROM pg_database ORDER BY oid;
            RETURN NEXT tmp;
        ELSE
            RETURN QUERY SELECT * FROM pg_database ORDER BY oid OFFSET i-1 LIMIT 1;
        END IF;
    END LOOP;
    RETURN;
END
$$ LANGUAGE plpgsql;

-- 选择结构写法1
CREATE OR REPLACE FUNCTION what_number(p integer) RETURNS text AS $$
BEGIN
    IF p = 0 THEN
        RETURN 'zero';
    ELSEIF p < 0 THEN
        RETURN 'lt zero';
    ELSE
        RETURN 'gt zero';
    END IF;
END
$$ LANGUAGE plpgsql;

-- 选择结构写法2
CREATE OR REPLACE FUNCTION what_number2(p integer) RETURNS text AS $$
BEGIN
    CASE p
        WHEN 0,1 THEN
            RETURN '0 or 1';
        ELSE
            RETURN 'not 0 and not 1';
    END CASE;
END
$$ LANGUAGE plpgsql;

-- 选择结构写法3
CREATE OR REPLACE FUNCTION is_zero(p integer) RETURNS text AS $$
BEGIN
    -- 不同于等值case，搜索case中的条件数目只能是1
    CASE
        WHEN p>0 THEN
            RETURN 'not eq zero';
        WHEN p<0 THEN
            RETURN 'not eq zero';
        ELSE
            RETURN 'eq zero';
    END CASE;
END
$$ LANGUAGE plpgsql;
