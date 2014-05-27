<?php
class MachineManager {
	// Get a list of machine IDs
	function getMachineList() {
		$query = <<<'SQL'
SELECT
	id
FROM
	machines
SQL;
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}

			return $list;
		}
	}
	
	// Get a list of machine IDs and their types
	function getMachineListWithTypeID() {
		$query = <<<'SQL'
SELECT
	id,
	type
FROM
	machines
SQL;
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}

			return $list;
		}
	}
	
	// Get a list of machine IDs and their types
	function getMachineListWithTypeName() {
		$query = <<<'SQL'
SELECT
	m.id,
	mt.name
FROM
	machines m
	JOIN machine_type mt ON m.type = mt.type
ORDER BY
	m.id
SQL;
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}

			return $list;
		}
	}

	// Get a machine type name given a machine type ID
	function getTypeName($machine_type) {
		$query = <<<'SQL'
SELECT
	name
FROM
	machine_type
WHERE
	type = ?
SQL;
		$stmt = $GLOBALS['mysqli']->prepare($query);
		$stmt->bind_param('i', $machine_type);
		
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}
			
			return $list;
		}
	}
	
	// Get a machine type name given a machine type ID
	function getTypeFromMachineID($machine_id) {
		$query = <<<SQL
SELECT
	mt.type,
	mt.name
FROM
	machines m
	JOIN machine_type mt ON m.type = mt.type
WHERE
	m.id = $machine_id
SQL;
		$stmt = $GLOBALS['mysqli']->prepare($query);
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}
			
			return $list;
		}
	}

	// Get a list of machine types and their names
	function getTypeList() {
		$query = <<<'SQL'
SELECT
	type,
	name
FROM
	machine_type
SQL;
		if(($result = $GLOBALS['mysqli']->query($query)) !== false) {
			$list = array();
			while(is_null($row = $result->fetch_assoc()) === false) {
				array_push($list, $row);
			}
			
			return $list;
		}
	}
}