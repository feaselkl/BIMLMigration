DECLARE
    @BaseSchemaName SYSNAME = N'dbo',
    @BaseTableName SYSNAME = N'DimCustomer',
    @BasePrimaryKeyName SYSNAME = N'CustomerKey';

/*
--Base case for the Predecessors CTE:  DimCustomer itself.
SELECT
    OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
    OBJECT_NAME(t.object_id) AS TableName,
    t.object_id AS TableID,
    0 AS Ordinal,
    CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
    CAST('' AS VARCHAR(8000)) AS JoinCriteria,
    'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
    'TODO' AS LookupColumns,
    'TODO' AS LookupColumnXML
FROM sys.tables t
WHERE
    t.type = 'U'
    AND t.name = @BaseTableName
    AND OBJECT_SCHEMA_NAME(t.object_id) = @BaseSchemaName
*/

/*
--Now add in LookupColumns and LookupColumnXML.
--LookupColumns is a comma-delimited list of key columns.
--Notice that < becomes &lt; and > becomes &gt;.  We'll fix those later.
SELECT
    OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
    OBJECT_NAME(t.object_id) AS TableName,
    t.object_id AS TableID,
    0 AS Ordinal,
    CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
    CAST('' AS VARCHAR(8000)) AS JoinCriteria,
    'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
    (
		SELECT
			CAST(STUFF
			(
				(
					SELECT
						', x.' + c.name
					FROM sys.key_constraints kc
						INNER JOIN sys.index_columns ic
							ON kc.parent_object_id = ic.object_id
							AND kc.unique_index_id = ic.index_id
						INNER JOIN sys.columns c
							ON ic.column_id = c.column_id
							AND ic.object_id = c.object_id
					WHERE
						kc.type = 'PK'
						AND kc.parent_object_id = t.object_id
					FOR XML PATH ('')
				), 1, 2, ''
			) AS VARCHAR(8000))
	) AS LookupColumns,
	(
        SELECT
            CAST(STUFF
            (
                (
                    SELECT
                        '<Column SourceColumn="' + c.name + '" TargetColumn="' + c.name + '" />'
                    FROM sys.key_constraints kc
                        INNER JOIN sys.index_columns ic
                            ON kc.parent_object_id = ic.object_id
                            AND kc.unique_index_id = ic.index_id
                        INNER JOIN sys.columns c
                            ON ic.column_id = c.column_id
                            AND ic.object_id = c.object_id
                    WHERE
                        kc.type = 'PK'
                        AND kc.parent_object_id = t.object_id
                    FOR XML PATH ('')
                ), 1, 0, ''
            ) AS VARCHAR(8000))
    ) AS LookupColumnXML
FROM sys.tables t
WHERE
    t.type = 'U'
    AND t.name = @BaseTableName
    AND OBJECT_SCHEMA_NAME(t.object_id) = @BaseSchemaName
*/

/*
--Predecessor's main case.
--We've looked at LookupColumns & LookupColumnXML so to keep the code concise,
--		we'll skip it the rest of the way.
--The main case uses foreign key constraints to link tables together.
WITH Predecessors AS
(
	SELECT
		OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
		OBJECT_NAME(t.object_id) AS TableName,
		t.object_id AS TableID,
		0 AS Ordinal,
		CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
		CAST('' AS VARCHAR(8000)) AS JoinCriteria,
		'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
		'LOOKED AT' AS LookupColumns,
		'LOOKED AT' AS LookupColumnXML
	FROM sys.tables t
	WHERE
		t.type = 'U'
		AND t.name = @BaseTableName
		AND OBJECT_SCHEMA_NAME(t.object_id) = @BaseSchemaName
	UNION ALL
	SELECT
		OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
		OBJECT_NAME(t.object_id) AS TableName,
		t.object_id AS TableID,
		tt.Ordinal - 1 AS Ordinal,
		CAST(Path + '/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/' AS VARCHAR(8000)) AS Path,
		CAST('' AS VARCHAR(8000)) AS JoinCriteria,
		'c.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
		'LOOKED AT' AS LookupColumns,
		'LOOKED AT' AS LookupColumnXML
	FROM sys.tables t
		INNER JOIN sys.foreign_keys f
			ON f.referenced_object_id = t.object_id
			AND f.parent_object_id <> f.referenced_object_id
		INNER JOIN Predecessors tt
			ON f.parent_object_id = tt.TableID
	WHERE
		t.type = 'U'
		AND Path NOT LIKE '%/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/%'
)
SELECT *
FROM Predecessors;
*/

/*
--Build Successors like we did Predecessors.
--Successors base case.
--NumberOfMoves and CurrentDirection are new here.
SELECT
    OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
    OBJECT_NAME(t.object_id) AS TableName,
    t.object_id AS TableID,
    0 AS Ordinal,
    CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
    CAST(0 AS INT) AS NumberOfMoves,
    '' AS CurrentDirection,
    CAST('' AS VARCHAR(8000)) AS JoinCriteria,
    'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
    'LOOKED AT' AS LookupColumns,
    'LOOKED AT' AS LookupColumnXML
FROM sys.tables t
WHERE
    t.type = 'U'
    AND t.name = @BaseTableName
*/

/*
--Successors CTE.
--In this step, we're moving "down" the tree from parent to child.
WITH Successors(SchemaName, TableName, TableID, Ordinal, Path, NumberOfMoves, CurrentDirection, JoinCriteria, WhereCriteria, LookupColumns, LookupColumnXML) AS
(
    SELECT
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
        OBJECT_NAME(t.object_id) AS TableName,
        t.object_id AS TableID,
        0 AS Ordinal,
        CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
        CAST(0 AS INT) AS NumberOfMoves,
        '' AS CurrentDirection,
        CAST('' AS VARCHAR(8000)) AS JoinCriteria,
        'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
        'LOOKED AT' AS LookupColumns,
        'LOOKED AT' AS LookupColumnXML
    FROM sys.tables t
    WHERE
        t.type = 'U'
        AND t.name = @BaseTableName
    UNION ALL
    SELECT
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
        OBJECT_NAME(t.object_id) AS TableName,
        t.object_id AS TableID,
        tt.Ordinal + 1 AS Ordinal,
        CAST(Path + '/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/' AS VARCHAR(8000)) AS Path,
        NumberOfMoves + CASE WHEN CurrentDirection = 'D' THEN 0 ELSE 1 END AS NumberOfMoves,
        'D' AS CurrentDirection,
        CAST('' AS VARCHAR(8000)) AS JoinCriteria,
        'c.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
        'LOOKED AT' AS LookupColumns,
        'LOOKED AT' AS LookupColumnXML
    FROM sys.tables t
        INNER JOIN sys.foreign_keys f
            ON f.parent_object_id = t.object_id
            AND f.parent_object_id <> f.referenced_object_id
        INNER JOIN Successors tt
            ON f.referenced_object_id = tt.TableID
    WHERE
        t.type = 'U'
        AND Path NOT LIKE '%/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/%'
        --We can change direction twice:  once to go "down" the tree to get child tables, and once more to get those
        --child tables' parents.  We don't need any more moves than that; this way, we get the minimum number of tables
        --necessary to populate our base table.
        AND NumberOfMoves + CASE WHEN CurrentDirection = 'D' THEN 0 ELSE 1 END < 2
)
SELECT *
FROM Successors;
*/

/*
--Now we want to include going down the tree and moving back up
--to capture foreign key constraints for ancestor tables.
WITH Successors(SchemaName, TableName, TableID, Ordinal, Path, NumberOfMoves, CurrentDirection, JoinCriteria, WhereCriteria, LookupColumns, LookupColumnXML) AS
(
    SELECT
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
        OBJECT_NAME(t.object_id) AS TableName,
        t.object_id AS TableID,
        0 AS Ordinal,
        CAST('/' + @BaseSchemaName + '.' + @BaseTableName + '/' AS VARCHAR(8000)) AS Path,
        CAST(0 AS INT) AS NumberOfMoves,
        '' AS CurrentDirection,
        CAST('' AS VARCHAR(8000)) AS JoinCriteria,
        'x.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
        'LOOKED AT' AS LookupColumns,
        'LOOKED AT' AS LookupColumnXML
    FROM sys.tables t
    WHERE
        t.type = 'U'
        AND t.name = @BaseTableName
    UNION ALL
    SELECT
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
        OBJECT_NAME(t.object_id) AS TableName,
        t.object_id AS TableID,
        tt.Ordinal + 1 AS Ordinal,
        CAST(Path + '/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/' AS VARCHAR(8000)) AS Path,
        NumberOfMoves + CASE WHEN CurrentDirection = 'D' THEN 0 ELSE 1 END AS NumberOfMoves,
        'D' AS CurrentDirection,
        CAST('' AS VARCHAR(8000)) AS JoinCriteria,
        'c.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
        'LOOKED AT' AS LookupColumns,
        'LOOKED AT' AS LookupColumnXML
    FROM sys.tables t
        INNER JOIN sys.foreign_keys f
            ON f.parent_object_id = t.object_id
            AND f.parent_object_id <> f.referenced_object_id
        INNER JOIN Successors tt
            ON f.referenced_object_id = tt.TableID
    WHERE
        t.type = 'U'
        AND Path NOT LIKE '%/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/%'
        --We can change direction twice:  once to go "down" the tree to get child tables, and once more to get those
        --child tables' parents.  We don't need any more moves than that; this way, we get the minimum number of tables
        --necessary to populate our base table.
        AND NumberOfMoves + CASE WHEN CurrentDirection = 'D' THEN 0 ELSE 1 END < 2
    UNION ALL
    SELECT
        OBJECT_SCHEMA_NAME(t.object_id) AS SchemaName,
        OBJECT_NAME(t.object_id) AS TableName,
        t.object_id AS TableID,
        tt.Ordinal - 1 AS Ordinal,
        CAST(Path + '/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/' AS VARCHAR(8000)) AS Path,
        NumberOfMoves + CASE WHEN CurrentDirection = 'U' THEN 0 ELSE 1 END AS NumberOfMoves,
        'U' AS CurrentDirection,
        CAST('' AS VARCHAR(8000)) AS JoinCriteria,
        'c.' + @BasePrimaryKeyName + ' = ?' AS WhereCriteria,
        'LOOKED AT' AS LookupColumns,
        'LOOKED AT' AS LookupColumnXML
    FROM sys.tables t
        INNER JOIN sys.foreign_keys f
            ON f.referenced_object_id = t.object_id
            AND f.parent_object_id <> f.referenced_object_id
        INNER JOIN Successors tt
            ON f.parent_object_id = tt.TableID
    WHERE
        t.type = 'U'
        AND Path NOT LIKE '%/' + OBJECT_SCHEMA_NAME(t.object_id) + '.' + OBJECT_NAME(t.object_id) + '/%'
        --No check here for NumberOfMoves because we want to be able to always move up the tree to find foreign key constraints.
)
SELECT *
FROM Successors;
*/

/*
--NON-RUNNABLE!
--Combine Predecessors and Successors together.
--Get all Predecessors and get any Successors not already
--	in the Predecessors list and which tie somehow to the base table.
--"Successors" can include totally unrelated ancestor tables
--	and if we don't filter them out, we'll get most of the data model.
SELECT
    p.SchemaName,
    p.TableName,
    p.TableID,
    p.Ordinal,
    p.JoinCriteria,
    p.Path,
    p.WhereCriteria,
    p.LookupColumns,
    p.LookupColumnXML
FROM Predecessors p
 
UNION ALL
 
SELECT
    s.SchemaName,
    s.TableName,
    s.TableID,
    s.Ordinal,
    s.JoinCriteria,
    s.Path,
    s.WhereCriteria,
    s.LookupColumns,
    s.LookupColumnXML
FROM Successors s
    LEFT OUTER JOIN Predecessors p
        ON s.TableID = p.TableID
WHERE
    p.TableID IS NULL
    AND s.Path LIKE '%/' + @BaseSchemaName + '.' + @BaseTableName + '/%'
*/