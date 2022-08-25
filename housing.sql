select * from dbo.property


--select data that going to use
select zipcode, property_type, bedrooms, price, has_availabiliTruey
from dbo.property
where bedrooms is not null

--min price
select zipcode, property_type, bedrooms, min(price) as min_price, has_availabiliTruey
from dbo.property
where zipcode  is not null and bedrooms > 0
group by zipcode,  property_type, bedrooms, has_availabiliTruey
ORDER by min_price asc


alter table dbo.property
alter COLUMN price FLOAT

alter table dbo.property
alter COLUMN zipcode INTEGER

DELETE FROM dbo.property WHERE zipcode ='99
98122'

-- zipcode with one property type with their average price
select  zipcode, count(zipcode) as zipcode_count, property_type, avg(price) as average_price
from dbo.property
where zipcode  is not null 
group by zipcode, property_type
order by zipcode DESC

-- extra people 
select  zipcode, count(zipcode) as zipcode_count, property_type, avg(price) as average_price, extra_people
from dbo.property
where zipcode  is not null 
group by zipcode, property_type, extra_people
order by zipcode DESC

--scoring rate
select zipcode, review_scores_rating
from dbo.property
group BY zipcode, review_scores_rating


--amenities
SELECT zipcode, property_type, price, amenities1, amenities2, amenities3, amenities4, amenities5, amenities6, amenities7,
amenities8, amenities9, amenities10, amenities11, amenities12, amenities13, amenities14,
amenities15, amenities16, amenities17, amenities18, amenities19, amenities20, amenities21
from dbo.property
where amenities1 is not NULL





