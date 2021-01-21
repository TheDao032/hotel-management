-- 2021-16-01
-- Nguyen The Dao

-- Function

create or replace function check_existed_id(id text)
returns text
language plpgsql
as
$$
declare
   result text;
begin
    if (id_acc NOT IN (SELECT id_acc FROM tbl_account WHERE id_acc = id )) then
        result := id;
    else
        result := '';
    end if;
	return result;
end
$$;
