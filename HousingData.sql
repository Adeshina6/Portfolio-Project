select * from ..HousingData

--Standardized Date Format
select SaleDateConverted, convert(Date, SaleDate) from ..HousingData

Update HousingData
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table HousingData
Add SaleDateConverted Date;

Update HousingData
Set SaleDateConverted = CONVERT(Date, SaleDate)




--Populate PropertyAddress Data

select * from ..HousingData
--where PropertyAddress is null
Order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
	  from ..HousingData a
	  join ..HousingData b
	  on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
	  where a.PropertyAddress is null

Update a
Set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
 from ..HousingData a
	  join ..HousingData b
	  on a.ParcelID = b.ParcelID
	  and a.[UniqueID ] <> b.[UniqueID ]
	  where a.PropertyAddress is null

--Breaking Address into Individual Columns (Addres, City, State)
select PropertyAddress
	  from ..HousingData

--select 
--PARSENAME (replace(PropertyAddress, ',', '.'),2),
--PARSENAME (replace(PropertyAddress, ',', '.'),1)
--from ..HousingData


select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

from ..HousingData

Alter Table HousingData
Add PropertySplitAddress nvarchar(255);

Update HousingData
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table HousingData
Add PropertySplitCity nvarchar(255);

Update HousingData
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select 
Parsename (replace(OwnerAddress, ',','.'), 3), 
Parsename (replace(OwnerAddress, ',','.'), 2),
Parsename (replace(OwnerAddress, ',','.'), 1) 
from ..HousingData


Alter Table HousingData
Add OwnerSplitAddress nvarchar(255);

Update HousingData
Set OwnerSplitAddress = Parsename (replace(OwnerAddress, ',','.'), 3)

Alter Table HousingData
Add OwnerSplitCity nvarchar(255);

Update HousingData
Set OwnerSplitCity = Parsename (replace(OwnerAddress, ',','.'), 2)

Alter Table HousingData
Add OwnerSplitState nvarchar(255);

Update HousingData
Set OwnerSplitState = Parsename (replace(OwnerAddress, ',','.'), 1)


select * from ..HousingData




--Change Y and N to Yes and No in SoldvsVacant column
Select distinct SoldAsVacant, COUNT(SoldAsVacant)
from ..HousingData
Group by SoldAsVacant
Order by 2

Select distinct SoldAsVacant , 
 case when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	  else SoldAsVacant
	  end 
	  from ..HousingData

--Alter Table HousingData
--Add SoldVacant nvarchar(255);

Update HousingData
Set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
  when SoldAsVacant = 'Y' then 'Yes'
  else SoldAsVacant
  end 
  

--Remove Duplicates
With RowNumCTE AS (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num
from ..HousingData
--order by ParcelID
)
Select * from RowNumCTE
where row_num > 1
order by PropertyAddress






--Delete Unused Columns

select * from ..HousingData

Alter Table HousingData
Drop Column OwnerAddress, PropertyAddress,TaxDistrict

Alter Table HousingData
Drop Column SaleDate, SoldVacant