-- 参数引用
-- 函数重载
CREATE FUNCTION mid1(varchar, integer, varchar) RETURNS varchar
AS $$
BEGIN
    RETURN substr($1, $2, $3);
END
$$
LANGUAGE plpgsql;

CREATE FUNCTION mid2(keyfield varchar, start integer) RETURNS varchar
AS $$
BEGIN
    RETURN substr(keyfield, start);
END
$$
LANGUAGE plpgsql;

-- 条件表达式
CREATE OR REPLACE FUNCTION format_us_full_name(
    prefix text, firstname text,
    mi text, lastname text,
    suffix text,
) RETURNS text
AS $$

DECLARE
    fname_mi text;
    fmi_lname text;
    prefix_fmil text;
    pfmil_suffix text;

BEGIN
    fname_mi := CONCAT_WS

