/*
CLEANING DATA IN SQL
*/

Select * from Portfolio_1..NashvilleHousing

--Standardize Data Format
Alter table Portfolio_1..NashvilleHousing 
Add SaleDateConverted Date;

Update Portfolio_1..NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

--Populate Property Address Data
Select PropertyAddress
From Portfolio_1..NashvilleHousing
Where PropertyAddress is Null

Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_1..NashvilleHousing a
JOIN Portfolio_1..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	--and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_1..NashvilleHousing a
JOIN Portfolio_1..NashvilleHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

--Breaking our Property Address Into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio_1..NashvilleHousing

Select 
Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio_1..NashvilleHousing

Alter table Portfolio_1..NashvilleHousing 
Add PropertySplitAddress nvarchar(255);

Update Portfolio_1..NashvilleHousing
Set PropertySplitAddress = Substring (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table Portfolio_1..NashvilleHousing 
Add PropertySplitCity nvarchar(255);

Update Portfolio_1..NashvilleHousing
Set PropertySplitCity = Substring (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Breaking our Property Address Into Individual Columns (Address, City, State)
Select OwnerAddress
From Portfolio_1..NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From Portfolio_1..NashvilleHousing

Alter table Portfolio_1..NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);

Update Portfolio_1..NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter table Portfolio_1..NashvilleHousing 
Add OwnerSplitCity nvarchar(255);

Update Portfolio_1..NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter table Portfolio_1..NashvilleHousing 
Add OwnerSplitState nvarchar(255);

Update Portfolio_1..NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

--Change Y and N to Yes and No in 'Sold as Vacant' Column
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From Portfolio_1..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From Portfolio_1..NashvilleHousing

Update Portfolio_1..NashvilleHousing
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From Portfolio_1..NashvilleHousing

--Remove Duplicates
With RowNumCTE as (
Select *,
	Row_Number() Over (
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
					UniqueID
					) row_num

From Portfolio_1..NashvilleHousing
)
Delete
From RowNumCTE
Where row_num > 1

--Delete Unused Columns
Alter Table Portfolio_1..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolio_1..NashvilleHousing
Drop Column SaleDate