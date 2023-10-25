USE [PortfolioProject]

/*
	Cleaning Data in SQL Queries
*/

select *
from [dbo].NashvilleHousing

/*
	Standarize Date Format
*/

select SaleDate, convert(Date, SaleDate)
from [dbo].NashvilleHousing

--this does not work
update NashvilleHousing
set SaleDate = convert(Date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date

update NashvilleHousing
set SaleDateConverted = convert(Date, SaleDate)

-- at this point we have created a new Sales Date column with the right format

/*
	Populate Property Address Data
*/

select *
from [dbo].NashvilleHousing as t
where t.PropertyAddress is null
order by ParcelID


-- First, we'll check if we can get the PropertyAddress from another property with the same ParcelID 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [dbo].NashvilleHousing a
join [dbo].NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Now lets update those property addresses with an update statement
update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [dbo].NashvilleHousing a
join [dbo].NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


/*
	Breaking out Address into Individual Columns (Address, City, State)
*/

select PropertyAddress
from [dbo].NashvilleHousing

-- lets get the address first
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from [dbo].NashvilleHousing

-- Now that we have the address and the city lets create those two new columns
-- New Column PropertySplitAddress and populate it
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)
update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

-- New Column PropertySplitCity and populate it
alter table NashvilleHousing
add PropertySplitCity nvarchar(255)
update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

-- Just to check the result
select PropertySplitAddress, PropertySplitCity, PropertyAddress
from [dbo].NashvilleHousing

-- Now lets work with the OwnerAddress
select OwnerAddress
from [dbo].NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from [dbo].NashvilleHousing

-- Now that we know how we can split the data, lets create new columns and populate them
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255), OwnerSplitCity nvarchar(255), OwnerSplitState nvarchar(50)
update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
, OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Just to check everything
select *
from [dbo].NashvilleHousing


/* 
	Change Y and N to Yes and No in column "SoldAsVacant"
*/

select distinct SoldAsVacant, count(SoldAsVacant)
from [dbo].NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
END
from [dbo].NashvilleHousing

-- Now we actually update the coloms with Yes and No.

update [dbo].NashvilleHousing
set SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant 
END



/*
	REMOVE DUPLICATES
	To remove actual data from tables should not be a standard practice
	but for the purpose of this demo project, we're going to remove some 
	duplicate data
*/

-- With this we get all the rows that have a duplicate
with RowNumCTE as (
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID
	) row_num
from [dbo].NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
Where row_num>1


-- We can use the same query but at the end instead of select we delete them
with RowNumCTE as (
select *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	order by UniqueID
	) row_num
from [dbo].NashvilleHousing
--order by ParcelID
)
DELETE  
from RowNumCTE
Where row_num>1



/*
	REMOVE Unused Columns
	Again, to remove actual data from tables should not be a standard practice
	but for the purpose of this demo project, we're going to remove some
	columns that are not being used for this demo project
*/

select *
from [dbo].NashvilleHousing

ALTER TABLE [dbo].NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate