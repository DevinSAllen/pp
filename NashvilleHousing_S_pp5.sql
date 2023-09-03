/* Data Cleaning */

SELECT * FROM NashvilleHousing_pp5.dbo.NashvilleHousing


-- Standardizing the Date Format

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE


-- Populating "PropertyAddress" Data

SELECT * FROM NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL


-- Splitting "PropertyAddress" Field Using SUBSTRINGs

	SELECT PropertyAddress FROM NashvilleHousing

	SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
	FROM NashvilleHousing

	ALTER TABLE NashvilleHousing 
	ADD Address NVARCHAR(255)

	UPDATE NashvilleHousing
	SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

	ALTER TABLE NashvilleHousing 
	ADD City NVARCHAR(255)

	UPDATE NashvilleHousing
	SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Splitting "OwnerAddress" Field Using PARSENAME

	SELECT OwnerAddress FROM NashvilleHousing

	SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	FROM NashvilleHousing

	ALTER TABLE NashvilleHousing 
	ADD OwnersAddress NVARCHAR(255)

	UPDATE NashvilleHousing
	SET OwnersAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

	ALTER TABLE NashvilleHousing 
	ADD OwnersCity NVARCHAR(255)

	UPDATE NashvilleHousing
	SET OwnersCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

	ALTER TABLE NashvilleHousing 
	ADD OwnersState NVARCHAR(255)

	UPDATE NashvilleHousing
	SET OwnersState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing 'Y' & 'N' to 'Yes' & 'No' in the "SoldAsVacant" Field

	SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM NashvilleHousing
	GROUP BY SoldAsVacant
	ORDER BY 2

	SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
	FROM NashvilleHousing

	UPDATE NashvilleHousing
	SET SoldAsVacant = CASE 
		 WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


-- Removing Duplicates Using a CTE

WITH RowNumCTE AS 
(SELECT *,
ROW_NUMBER() 
OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) Row_Num
FROM NashvilleHousing)
DELETE FROM RowNumCTE
WHERE Row_Num > 1
