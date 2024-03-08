DECLARE @TableName VARCHAR(255)
DECLARE @INDEXNAME VARCHAR(255)
DECLARE @sql NVARCHAR(500)

DECLARE TableCursor CURSOR FOR
SELECT name AS TableName
FROM sys.tables

OPEN TableCursor
FETCH NEXT FROM TableCursor INTO @TableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
	
			DECLARE INDEXCursor CURSOR FOR
			SELECT NAME AS INDEXNAME 
			FROM SYS.indexes A
			WHERE EXISTS 
						( SELECT 1 FROM SYS.TABLES B
							WHERE A.object_id = B.object_id 
							AND B.NAME = @TableName)
			
			OPEN INDEXCursor
			FETCH NEXT FROM INDEXCursor INTO @INDEXNAME
			
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					SET @sql = 'ALTER INDEX ' + '[' + @INDEXNAME + ']' + ' ON ' + '[' + @TableName + ']' + ' REBUILD '
					PRINT('EXEC: ' + @TableName + '      -      ' + @INDEXNAME + '      -      STARTED AT: ' + FORMAT(GETDATE(),'dd-MM HH:mm')   )
					EXEC  (@sql)
					PRINT('DONE: ' + @TableName + '      -      ' + @INDEXNAME + '      -      ENDED AT : ' + FORMAT(GETDATE(),'dd-MM HH:mm')   )
					
					SET @sql = 'ALTER INDEX ' + '['+@INDEXNAME+']' + ' ON ' + '[' + @TableName + ']' + ' reorganize '
					PRINT('EXEC: ' + @TableName + '      -      ' + @INDEXNAME + '      -      STARTED AT : ' + FORMAT(GETDATE(),'dd-MM HH:mm')   )
					EXEC  (@sql)
					PRINT('DONE: ' + @TableName + '      -      ' + @INDEXNAME + '      -      ENDED AT : ' + FORMAT(GETDATE(),'dd-MM HH:mm')   )
						
				FETCH NEXT FROM INDEXCursor INTO @INDEXNAME
				END
			
			CLOSE INDEXCursor
			DEALLOCATE INDEXCursor
	
	FETCH NEXT FROM TableCursor INTO @TableName
	END

CLOSE TableCursor
DEALLOCATE TableCursor
GO