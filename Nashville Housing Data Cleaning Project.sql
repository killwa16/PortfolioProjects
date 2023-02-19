SELECT * 
From projects.dbo.NashvilleHousing

-- making the date uniform by taking the hour parameter

SELECT SaleDate, CONVERt(Date, SaleDate)
From projects.dbo.NashvilleHousing;

Update projects.dbo.NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE projects.dbo.NashvilleHousing
Add SaleDateConverted Date;

Update projects.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDate, SaleDateConverted
from projects.dbo.NashvilleHousing

-- populate property address data
SELECT PropertyAddress
From projects.dbo.NashvilleHousing
Where PropertyAddress is NULL


SELECT *
From projects.dbo.NashvilleHousing
Where PropertyAddress is NULL
Order by ParcelID
--Noticed that parcelID corresponds to a property address.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
From projects.dbo.NashvilleHousing a 
JOIN projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHere a.PropertyAddress is Null

-- replacing the nulls with the address that matches the parcel id.
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
From projects.dbo.NashvilleHousing a 
JOIN projects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Seperating the address to individual columns (Address, City, State)

--Getting the Address and the City
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FRom projects.dbo.NashvilleHousing

ALTER TABLE projects.dbo.NashvilleHousing
Add PropertyStAddress NVARCHAR(255);

Update projects.dbo.NashvilleHousing
Set PropertyStAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE projects.dbo.NashvilleHousing
Add PropertyCity Nvarchar(255);

Update projects.dbo.NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FRom projects.dbo.NashvilleHousing


-- cleaning the owner address
SELECT OwnerAddress
FRom projects.dbo.NashvilleHousing


--using parsename to split the owner address
Select
Parsename(REPLACE(OwnerAddress,',','.'),3)
,Parsename(REPLACE(OwnerAddress,',','.'),2)
,Parsename(REPLACE(OwnerAddress,',','.'),1)
FRom projects.dbo.NashvilleHousing

ALTER TABLE projects.dbo.NashvilleHousing
Add OwnerStAddress NVARCHAR(255);

Update projects.dbo.NashvilleHousing
Set OwnerStAddress = Parsename(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE projects.dbo.NashvilleHousing
Add OwnerCity Nvarchar(255);

Update projects.dbo.NashvilleHousing
Set OwnerCity = Parsename(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE projects.dbo.NashvilleHousing
Add OwnerState NVARCHAR(255);

Update projects.dbo.NashvilleHousing
Set OwnerState = Parsename(REPLACE(OwnerAddress,',','.'),1)




-- Change Y and N to 'Yes' and 'No' in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FRom projects.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
,	Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FRom projects.dbo.NashvilleHousing

Update projects.dbo.NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

--Remove Duplicates
-- Creating a CTE
With RowNumCTE as(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) row_num
FRom projects.dbo.NashvilleHousing
)
Delete
From RowNumCTE
Where row_num >1


--Delete Relatively Useless Columns
Select *
FRom projects.dbo.NashvilleHousing

ALTER TAble projects.dbo.NashvilleHousing
Drop column PropertyAddress, OwnerAddress, TaxDistrict, SaleDate