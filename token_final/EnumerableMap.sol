// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

library EnumerableMap {
    using EnumerableSet for EnumerableSet.Set;

    struct Map {
        // Storage of keys
        EnumerableSet.Set _keys;
        mapping(address => mapping(address => uint256)) _values;
    }

    function set(
        Map storage map,
        address ownerkey,
        address rewardKey,
        uint256 value
    ) internal returns (bool) {
        map._values[ownerkey][rewardKey] = value;
        
        return map._keys.add(ownerkey);
    }

    function remove(
        Map storage map,
        address ownerkey,
        address rewardKey
    ) 
        internal
        returns (bool)
    {
        map._values[ownerkey][rewardKey] = 0;
        
        return map._keys.remove(ownerkey);
    }

    function contains(
        Map storage map,
        address key
    )
        internal
        view
        returns (bool)
    {
        return map._keys.contains(key);
    }

    function length(Map storage map)
        internal
        view
        returns (uint256)
    {
        return map._keys.length();
    }

    function keyAt(Map storage map, uint256 index)
        internal
        view
        returns (address)
    {
        return map._keys.at(index);
    }
    
    function indexOfKey(Map storage map, address key)
        internal
        view
        returns (int256)
    {
        return map._keys.indexOf(key);
    }

    function get(
        Map storage map,
        address ownerkey,
        address rewardKey
    ) 
        internal
        view
        returns (uint256)
    {
        uint256 value = contains(map, ownerkey) ?
            map._values[ownerkey][rewardKey] : 0;

        return value;
    }
}
