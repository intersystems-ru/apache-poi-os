/// Exposes an api for Excel books
Class isc.poi.Book Extends %Persistent
{

/// Sheet information
/// $lb($lb(rowCount, listName), $lb(rowCount2, listName2), ... )
Property info As %List;

/// Sheet data
/// data(rownum) = $lb(Cell1, Cell2, ..., CennN)
Property data As %List [ MultiDimensional ];

/// Create object from list and do some postprocessing
Method %OnNew(list As %ListOfDataTypes) As %Status [ Private, ServerOnly = 1 ]
{
	quit:list.Count()=1 $$$ERROR($$$GeneralError, list.GetAt(1))
	
	set info = list.GetAt(list.Count())
	set info = $lfs(info, $c(1,1))
	for i=1:1:$ll(info) {
		set $list(infoFinal, i) = $lfs($lg(info, i), $c(1))
	}
	set ..info = infoFinal
	do list.RemoveAt(list.Count())
	
	merge ..data = list.Data
	
	
	set key = ""
	for {
		set key=$order(..data(key), 1, value) 
		quit:key=""
		// replace $c(0) with empty elements
		set value = $replace(value, $lb($c(0)), $lb())
		
		// Make $lb lists
		set value = $lfs(value, $c(1))
		
		// TODO java-side set casted values
		// TODO dates
		if '$listvalid(value) {
			set ^isc.poi.Book1($i(^isc.poi.Book1))= value
			set ^isc.poi.Book2($i(^isc.poi.Book2))= key
		}
		
		set ..data(key) = value
	}	
	
	quit $$$OK
}

Method getSheet(sheetNum As %Integer, Output sheet)
{
	kill sheet
	quit:sheetNum>..getSheetCount()
	set offset = ..getSheetOffset(sheetNum)
	for i=offset+1:1:offset+..getSheetRowCount(sheetNum) {
		set sheet($i(sheet)) = ..data(i)
	}
}

Method getRow(sheetNum As %Integer, rowNum As %Integer) As %List
{
	quit:sheetNum>..getSheetCount() ""
	quit:rowNum>..getSheetRowCount(sheetNum) ""
	set offset = ..getSheetOffset(sheetNum) + rowNum
	quit ..data(offset)
}

Method getCell(sheetNum As %Integer, rowNum As %Integer, colNum As %Integer)
{
	quit:sheetNum>..getSheetCount() ""
	quit:rowNum>..getSheetRowCount(sheetNum) ""
	set row = ..getRow(sheetNum, rowNum)
	quit $lg(row, colNum)
}

Method getSheetOffset(sheetNum As %Integer) As %Integer
{
	quit:sheetNum>..getSheetCount() ""
	set offset = 0
	for i=1:1:(sheetNum-1) {
		set offset = offset + ..getSheetRowCount(i)
	}
	quit offset
}

Method getSheetRowCount(sheetNum As %Integer) [ CodeMode = expression ]
{
$lg($lg(..info, sheetNum))
}

Method getSheetCount() [ CodeMode = expression ]
{
$ll(..info)
}

Method getSheetName(sheetNum As %Integer) [ CodeMode = expression ]
{
$lg($lg(..info, sheetNum), 2)
}

Storage Default
{
<Data name="BookDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>info</Value>
</Value>
</Data>
<DataLocation>^isc.poi.BookD</DataLocation>
<DefaultData>BookDefaultData</DefaultData>
<IdLocation>^isc.poi.BookD</IdLocation>
<IndexLocation>^isc.poi.BookI</IndexLocation>
<StreamLocation>^isc.poi.BookS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

