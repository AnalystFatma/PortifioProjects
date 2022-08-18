
--cleanning data in sql queries
select * 
from dbo.[Nashville Housing Data for Data Cleaning]


--1.standrize data format

--convert from datetime to date

alter TABLE [Nashville Housing Data for Data Cleaning]
add SaleDateConverted DATE

update [Nashville Housing Data for Data Cleaning]
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted
from dbo.[Nashville Housing Data for Data Cleaning]

alter table [Nashville Housing Data for Data Cleaning]
drop COLUMN SaleDateConverted



--2.populate property address data

select *
from dbo.[Nashville Housing Data for Data Cleaning]
where PropertyAddress is NULL

select a.ParcelID, a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a 
JOIN dbo.[Nashville Housing Data for Data Cleaning] b 
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.[Nashville Housing Data for Data Cleaning] a 
JOIN dbo.[Nashville Housing Data for Data Cleaning] b 
on a.ParcelID = b.ParcelID and a.UniqueID <> b.UniqueID

--3.breaking out address into indvidual columns (adress, city, state)

select PropertyAddress
from dbo.[Nashville Housing Data for Data Cleaning]

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Adress,--lookin for ,
--CHARINDEX(',',PropertyAddress),--, position
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress)) as City
from dbo.[Nashville Housing Data for Data Cleaning]

-----
alter TABLE [Nashville Housing Data for Data Cleaning]
add PropertySplitAdress NVARCHAR(50)

update [Nashville Housing Data for Data Cleaning]
set PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)
------
alter TABLE [Nashville Housing Data for Data Cleaning]
add PropertySplitCity NVARCHAR(50)

update [Nashville Housing Data for Data Cleaning]
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, len(PropertyAddress))



select PropertySplitAdress, PropertySplitCity
from dbo.[Nashville Housing Data for Data Cleaning]

-------------------------------

select OwnerAddress
from dbo.[Nashville Housing Data for Data Cleaning]


select PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from dbo.[Nashville Housing Data for Data Cleaning]


alter TABLE [Nashville Housing Data for Data Cleaning]
add OwnerSplitAdress NVARCHAR(50)

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitAdress= PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
----
alter TABLE [Nashville Housing Data for Data Cleaning]
add OwnerSplitCity NVARCHAR(50)

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

------
alter TABLE [Nashville Housing Data for Data Cleaning]
add OwnerSplitState NVARCHAR(50)

update [Nashville Housing Data for Data Cleaning]
set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select OwnerSplitAdress, OwnerSplitCity, OwnerSplitState
from dbo.[Nashville Housing Data for Data Cleaning]



------------------------------------------------------
--4.change Y and N to Yes and No in "SOLD AS VACANT" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.[Nashville Housing Data for Data Cleaning]
GROUP by SoldAsVacant

select SoldAsVacant,
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END
from dbo.[Nashville Housing Data for Data Cleaning];

-------

update [Nashville Housing Data for Data Cleaning]
set SoldAsVacant=  CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
         WHEN SoldAsVacant = 'N' THEN 'No'
         ELSE SoldAsVacant
         END


------------------------------------------------------
--5.remove duplicates
--CTE--
WITH RowNumCTE AS(
select *,
ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference order by UniqueID) as row_num

from dbo.[Nashville Housing Data for Data Cleaning]
--order by ParcelID
)
select * from RowNumCTE
WHERE row_num > 1
order by PropertyAddress

--delete  from RowNumCTE
--WHERE row_num > 1
--order by PropertyAddress


------------------------------------------------------
--6.delete unused columns
select *
from dbo.[Nashville Housing Data for Data Cleaning]

ALTER TABLE  dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  dbo.[Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate
