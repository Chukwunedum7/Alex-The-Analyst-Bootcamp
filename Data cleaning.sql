/*
Cleaning Data in SQL
*/

Select*
From [Portfolio Project].[dbo].[NashvilleHousing]

--Standardize date format

Select SaleDateConverted, Convert(Date,SaleDate) as NewSaleDate
From [Portfolio Project].[dbo].[NashvilleHousing]

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set SaleDate = Convert(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set SaleDateConverted = Convert(Date,SaleDate)


--Populating property Address


Select*
From [Portfolio Project].[dbo].[NashvilleHousing]
Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].[dbo].[NashvilleHousing] a
Join [Portfolio Project].[dbo].[NashvilleHousing] b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]


 Update a
 Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 From [Portfolio Project].[dbo].[NashvilleHousing] a
Join [Portfolio Project].[dbo].[NashvilleHousing] b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]


 --Breaking the Property address into address and city in different columns

 Select PropertyAddress
From [Portfolio Project].[dbo].[NashvilleHousing]

 Select
 SUBSTRING (PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
 SUBSTRING (PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress)) as Location
 From [Portfolio Project].[dbo].[NashvilleHousing]


Alter table [Portfolio Project].[dbo].[NashvilleHousing]
add PropertySplitAddress nvarchar(255);

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter table [Portfolio Project].[dbo].[NashvilleHousing]
add PropertyAddressCity nvarchar(255);

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set PropertyAddressCity =  SUBSTRING (PropertyAddress, Charindex(',', PropertyAddress)+1, LEN(PropertyAddress))


--SEPARATING OWNERADDRESS USING PARSENAME
Select OwnerAddress
From [Portfolio Project].[dbo].[NashvilleHousing]

Select
PARSENAME( Replace(OwnerAddress, ',','.'), 3) as OwnerSplitAddress,
PARSENAME( Replace(OwnerAddress, ',','.'), 2) as OwnerCity,
PARSENAME( Replace(OwnerAddress, ',','.'), 1) as OwnerState
From [Portfolio Project].[dbo].[NashvilleHousing]
Where OwnerAddress is not null

Alter table [Portfolio Project].[dbo].[NashvilleHousing]
add OwnerSplitAddress nvarchar(255);

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set OwnerSplitAddress = PARSENAME( Replace(OwnerAddress, ',','.'), 3)

Alter table [Portfolio Project].[dbo].[NashvilleHousing]
add OwnerCity nvarchar(255);

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set OwnerCity = PARSENAME( Replace(OwnerAddress, ',','.'), 2)

Alter table [Portfolio Project].[dbo].[NashvilleHousing]
add OwnerState nvarchar(255);

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set OwnerState = PARSENAME( Replace(OwnerAddress, ',','.'), 1)

--Changing Y and N in SoldAsVacant to Yes and No respectively

Select Distinct(Soldasvacant), Count(Soldasvacant)
From [Portfolio Project].[dbo].[NashvilleHousing]
Group by SoldAsVacant

Select Soldasvacant,
Case When Soldasvacant = 'Y' Then 'Yes'
     When Soldasvacant = 'N' Then 'No'
	 Else Soldasvacant
	 End
From [Portfolio Project].[dbo].[NashvilleHousing]

Update [Portfolio Project].[dbo].[NashvilleHousing]
Set SoldAsVacant= Case When Soldasvacant = 'Y' Then 'Yes'
     When Soldasvacant = 'N' Then 'No'
	 Else Soldasvacant
	 End

--Removing Duplicates
with RowNumCTE AS(
Select*, 
ROW_NUMBER() Over(
Partition by ParcelID,
		   propertyAddress,
		   SalePrice,
		   SaleDate,
		   LegalReference
		   Order by
		   UniqueID
		   ) row_num

From [Portfolio Project].[dbo].[NashvilleHousing]
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Deleting Unused Columns

Select*
From [Portfolio Project].[dbo].[NashvilleHousing]

ALter table [Portfolio Project].[dbo].[NashvilleHousing]
Drop Column TaxDistrict, PropertyAddress, SaleDate, OwnerAddress




