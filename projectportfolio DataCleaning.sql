--CLEANING DATA IN SQL QUIERIES

select *
from PROJECTPORTFOLIO..NASHVILEHOUSING
--where PropertyAddress is null
--order by 4


--STANDARDIZE DATE FORMAT
select SaleDateConverted, CONVERT(date, SaleDate) as saledateconvert
from PROJECTPORTFOLIO..NASHVILEHOUSING

Alter table NASHVILEHOUSING
Add SaleDateConverted date;

update NASHVILEHOUSING
set SaleDateConverted = CONVERT(date, SaleDate)


--POPULATE PROPERTY ADDRESS DATA
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PROJECTPORTFOLIO..NASHVILEHOUSING a
join PROJECTPORTFOLIO..NASHVILEHOUSING b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PROJECTPORTFOLIO..NASHVILEHOUSING a
join PROJECTPORTFOLIO..NASHVILEHOUSING b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

   --BREAKING ADDRESS INTO INDIVIDUAL COLUMNS
 

 select
 SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as Address,
 SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) as state
from PROJECTPORTFOLIO..NASHVILEHOUSING

Alter table NASHVILEHOUSING
Add SplitPropertyAddress nvarchar(255);

update NASHVILEHOUSING
set SplitPropertyAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

Alter table NASHVILEHOUSING
Add SplitCity nvarchar(255);

update NASHVILEHOUSING
set SplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))

--EASIER WAY USING PARSEANME

select 
PARSENAME(replace(owneraddress, ',', '.'), 3),
PARSENAME(replace(owneraddress, ',', '.'), 2),
PARSENAME(replace(owneraddress, ',', '.'), 1)
from PROJECTPORTFOLIO..NASHVILEHOUSING 

Alter table PROJECTPORTFOLIO..NASHVILEHOUSING
Add SplitownerAddress nvarchar(255);

update PROJECTPORTFOLIO..NASHVILEHOUSING
set SplitownerAddress = PARSENAME(replace(owneraddress, ',', '.'), 3)

Alter table PROJECTPORTFOLIO..NASHVILEHOUSING
Add SplitownerCity nvarchar(255);

update PROJECTPORTFOLIO..NASHVILEHOUSING
set SplitownerCity = PARSENAME(replace(owneraddress, ',', '.'), 2)

Alter table PROJECTPORTFOLIO..NASHVILEHOUSING
Add SplitownerState nvarchar(255);

update PROJECTPORTFOLIO..NASHVILEHOUSING
set SplitownerState = PARSENAME(replace(owneraddress, ',', '.'), 1)


select *
from PROJECTPORTFOLIO..NASHVILEHOUSING 
where SoldAsVacant = 'N'


--CHANGE Y & N TO YES AND NO USING CASE STATEMENT

select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
from PROJECTPORTFOLIO..NASHVILEHOUSING 
GROUP BY SoldAsVacant
ORDER BY 2

select SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end as EditedSoldAsVacant
from PROJECTPORTFOLIO..NASHVILEHOUSING 

update PROJECTPORTFOLIO..NASHVILEHOUSING
set 
SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

 --REMOVING DUPLICATES

 with RowNumCTE AS (
 SELECT *,
 ROW_NUMBER() OVER (
 PARTITION BY ParcelID,
              PropertyAddress,
			  saleprice,
			  saledate,
			  legalreference
			  order by 
			     uniqueID
			  ) Row_Numb
from PROJECTPORTFOLIO..NASHVILEHOUSING
--order by ParcelID
)
SELECT *
FROM RowNumCTE
WHERE Row_Numb >1
ORDER BY PropertyAddress


-- DELETE UNUSED COLUMN

select *
from PROJECTPORTFOLIO..NASHVILEHOUSING 

Alter table PROJECTPORTFOLIO..NASHVILEHOUSING 
 drop column propertyaddress, saledate, owneraddress, taxdistrict
