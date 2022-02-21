/*
    Simulate an unordered map in 'imperative language' (C++/Python/...)
        => Can iterate through keys, get value at index, delete, set key-value, ..
*/

// SPDX-License-Identifer: MIT
pragma solidity ^0.8.10;

library IterableMapping {
    struct Map {
        address[] keys;
        mapping(address => uint) values;
        mapping(address => uint) indexes;
        mapping(address => bool) existed;
    }

    function set(Map storage myMap, address _key, uint _value) public {
        if (!myMap.existed[_key]) {
            myMap.keys.push(_key);
            myMap.indexes[_key] = myMap.keys.length - 1;
            myMap.existed[_key] = true;
        }

        myMap.values[_key] = _value;
    }

    function size(Map storage myMap) public view returns (uint) {
        return myMap.keys.length;
    }

    function get(Map storage myMap, address _key) public view returns (uint) {
        return myMap.values[_key];
    }

    function keyAtIndex(Map storage myMap, uint idx) public view returns (address) {
        return myMap.keys[idx];
    }

    function remove(Map storage myMap, address _key) public {
        if (!myMap.existed[_key]) return;

        uint index = myMap.indexes[_key];

        uint lastIndex = myMap.keys.length-1;
        address lastKey = myMap.keys[lastIndex];

        myMap.keys[index] = lastKey;
        myMap.indexes[lastKey] = index;

        myMap.keys.pop();
        delete myMap.existed[_key];
        delete myMap.values[_key];
        delete myMap.indexes[_key];
    }
}

contract TestIterableMapping {
    using IterableMapping for IterableMapping.Map;
    IterableMapping.Map private testMap;

    function testIterableMap() public {
        testMap.set(address(1), 1);
        testMap.set(address(2), 5);
        testMap.set(address(2), 2);
        testMap.set(address(3), 3);

        require(testMap.size() == 3, "Wrong size!");

        for (uint i = 0; i < testMap.size(); i++) {
            address addr = testMap.keyAtIndex(i);
            require(testMap.get(addr) == i+1, "Wrong value!");
        }

        testMap.remove(address(1));
        // Now it is [address(3), address(2)]

        require(testMap.size() == 2, "Wrong size after modification!");
        require(testMap.keyAtIndex(0) == address(3), "Wrong index at 0!");
        require(testMap.keyAtIndex(1) == address(2), "Wrong index at 1!");
    }

}
