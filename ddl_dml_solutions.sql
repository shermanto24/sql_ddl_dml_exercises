-- Creating and populating initial tables
create or replace table sh_target
(
    id int,
    value char
);

insert into sh_target values
    (1, 'A'),
    (2, 'A'),
    (3, null),
    (5, 'A'),
    (8, 'A'),
    (9, null),
    (10, null)
;

create or replace table sh_source
(
    id int,
    value char
);

insert into sh_source values
    (1, null),
    (2, 'B'),
    (4, 'B'),
    (8, 'B'),
    (9, 'B'),
    (10, null),
    (11, null)
;

table sh_target;
table sh_source;

--*-* Exercise 1: update *-*--

create or replace table sh_result as
    select *
    from sh_target
;

-- Only sets value when ids match
update sh_result as r
set r.value = s.value
    from sh_source as s
    where r.id = s.id
;

select * from sh_result
order by id asc;

--*-* Exercise 2: update_null_fill *-*--

create or replace table sh_result as
    select *
    from sh_target
;

update sh_result as r
set r.value = s.value
    from sh_source as s
    where
        r.id = s.id and
        r.value is null
;

select * from sh_result
order by id asc;

--*-* Exercise 3: update_override *-*--

create or replace table sh_result as
    select *
    from sh_target
;

update sh_result as r
set r.value = s.value
    from sh_source as s
    where
        r.id = s.id and
        s.value is not null
;

select * from sh_result
order by id asc;

--*-* Exercise 4: merge *-*--

create or replace table sh_result as
    select t.*
    from sh_target
;

merge into sh_result as r
using sh_source as s
    on r.id = s.id
when matched then -- replace w/ value from source
    update
    set r.value = s.value
when not matched then -- s.id doesn't exist in r, so insert from source into target
    insert (r.id, r.value) -- identifies destination columns
    values (s.id, s.value) -- passes values from source row
;

select * from sh_result
order by id asc;
    
--*-* Exercise 5: merge_null_fill *-*--

create or replace table sh_result as
    select *
    from sh_target
;

-- Only update values when target is null
merge into sh_result as r
using sh_source as s
    on r.id = s.id
when matched then
    update
    set r.value = coalesce(r.value, s.value)
when not matched then
    insert (r.id, r.value)
    values (s.id, s.value)
;

select * from sh_result
order by id asc;

--*-* Exercise 6: merge_override *-*--

create or replace table sh_result as
    select *
    from sh_target
;

-- Update when ids match and r.value is not null
-- If source id exists and target id doesn't, insert source row
merge into sh_result as r
using sh_source as s
    on r.id = s.id
when matched then
    update
    set r.value = coalesce(s.value, r.value) -- similar to merge_null_fill, but order switched
    -- when r.value & null s.value - keep r.value
    -- when r.value & s.value - use s.value
    -- when null r.value and s.value - use s.value
    -- aka: keep s.value except for when null, replace with r.value
when not matched then
    insert (r.id, r.value)
    values (s.id, s.value)
;

select * from sh_result
order by id asc;

--*-* Exercise 7: append *-*--

create or replace table sh_result as
    select *
    from sh_target
;

insert into sh_result -- optional: (id, value)
    select *
    from sh_source
;

select * from sh_result
order by
    id asc,
    value asc;