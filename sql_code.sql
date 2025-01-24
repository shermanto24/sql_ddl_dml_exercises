--create target and source tables
--to prevent the target table from being altered with each exericse, a copy of it will be made each time it's used

create table target (
    id int,
    value varchar
);

insert into target (id, value)
values
    (1, 'A'),
    (2, 'A'),
    (3, null),
    (5, 'A'),
    (8, 'A'),
    (9, null),
    (10, null);

create table source (
    id int,
    value varchar
);

insert into source (id, value)
values
    (1, null),
    (2, 'B'),
    (4, 'B'),
    (8, 'B'),
    (9, 'B'),
    (10, null),
    (11, null);



--exercise 1: update
create table update_target as
    select *
    from target;


update update_target
set update_target.value = source.value
from source
where update_target.id = source.id;





--exercise 2: update_null_fill
create table update_null_fill_target as
    select *
    from target;


update update_null_fill_target
set update_null_fill_target.value = source.value
from source
where
    update_null_fill_target.id = source.id
    and update_null_fill_target.value is null;





--exercise 3: update_override
create table update_override_target as
    select *
    from target;


update update_override_target
set update_override_target.value = source.value
from source
where
    update_override_target.id = source.id
    and source.value is not null;





--exercise 4: merge
create table merge_target as
    select *
    from target;


merge into merge_target
using source
    on merge_target.id = source.id
when matched then
    update
    set merge_target.value = source.value
when not matched then
    insert (merge_target.id, merge_target.value)
    values (source.id, source.value);





--exercise 5: merge_null_fill
create table merge_null_fill_target as
    select *
    from target;


merge into merge_null_fill_target
using source
    on merge_null_fill_target.id = source.id
when matched then
    update
    set merge_null_fill_target.value = coalesce(merge_null_fill_target.value, source.value)
when not matched then
    insert (merge_null_fill_target.id, merge_null_fill_target.value)
    values (source.id, source.value);





--exercise 6: merge_override
create table merge_override_target as
    select *
    from target;


merge into merge_override_target
using source
    on merge_override_target.id = source.id
when matched then
    update
    set merge_override_target.value = coalesce(source.value, merge_override_target.value)
when not matched then
    insert (merge_override_target.id, merge_override_target.value)
    values (source.id, source.value);





--exercise 7: append
create table append_target as
    select *
    from target;


insert into append_target (id, value)
    select * from source;