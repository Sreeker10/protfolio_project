use portpro
select * from dbo.HousingData

-- Convertion of Date into Datetime and Date 

Alter table dbo.HousingData
add dateConverted datetime

update dbo.HousingData
set dateConverted = CONVERT(datetime,SaleDate)

select dateConverted from dbo.HousingData


--populate Property Address data

select PropertyAddress from dbo.HousingData 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress from dbo.HousingData a
	join dbo.HousingData b
	on b.ParcelID = a.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.HousingData a
	join dbo.HousingData b
	on b.ParcelID = a.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking of Address into individual Blanks(columns of Data)

select PropertyAddress
from dbo.HousingData


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as Address
from dbo.HousingData

alter table dbo.HousingData
add Address Nvarchar(255),
city Nvarchar(255)

update dbo.HousingData
set 
Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))
from dbo.HousingData

select Address,city from dbo.HousingData

select OwnerAddress
from dbo.HousingData

-- Using ParseName

select 
PARSENAME(replace(OwnerAddress,',','.'),1),
ParseName(replace(OwnerAddress,',','.'),2),
ParseName(replace(OwnerAddress,',','.'),3)
from dbo.HousingData					  


alter table dbo.HousingData
add
	owneradd Nvarchar(255),
	ownercity Nvarchar(255),
	ownerstate Nvarchar(255)

update dbo.HousingData
set 
	owneradd = ParseName(replace(OwnerAddress,',','.'),3),
	ownercity = ParseName(replace(OwnerAddress,',','.'),2),
	ownerstate = PARSENAME(replace(OwnerAddress,',','.'),1)
from dbo.HousingData

select * from dbo.HousingData

-- change 0 or 1 in 'SoldAsVaccant' to Yes or No

select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from dbo.HousingData
group by SoldAsVacant

  -- changing the DataType from int to varchar

alter table dbo.HousingData
alter column SoldAsVacant varchar(255)

update dbo.HousingData
set SoldAsVacant = CASE 
		when SoldAsVacant=0 then 'Yes'
		else 'No'
		end

-- remove duplicates

with rownumCTE as (
	select *,
		ROW_NUMBER() over (
		partition by ParcelId,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID
		) row_num
	from dbo.HousingData
)

select *  from
rownumCTE where
row_num >1

-- delete unused addresses

alter table dbo.HousingData
drop column OwnerAddress,TaxDistrict,PropertyAddress

alter table dbo.HousingData
drop column dateConverted


select * from dbo.HousingData