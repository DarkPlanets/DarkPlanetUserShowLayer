/**
 *Submitted for verification at FtmScan.com on 2021-10-11
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
    
    function toString(uint256 value) internal pure returns (string memory) {
    
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}


interface RarityLandStorage {
    function getLandFee(uint256 summoner)external view returns(bool,uint256);
    function getLandCoordinates(uint256 summoner) external view returns(bool,uint256 x,uint256 y);
    function getSummonerCoordinates(uint256 summoner)external view returns(bool,uint256 x,uint256 y);
    function getLandIndex(uint256 summoner)external view returns(bool result,uint256 landIndex);
    function getSummoner(uint256 lIndex)external view returns(bool result,uint256 summoner);
    function totalSupply() external view returns (uint256 supply);
    function getLandState(uint256 summoner)external view returns(bool,bool);
    function getLandIncome(uint256 summoner)external view returns(bool result,uint256 income);
    function getLandSummoners(uint256 summoner)external view returns(bool result,uint256 amount);
    function loadLandInfo(uint256 targetSummoner)external view returns(
        bool result, 
        string memory name,
        string memory des,
        uint256 indexType,
        string memory landContentIndex
        );
}

interface rarity {
    function level(uint) external view returns (uint);
    function getApproved(uint) external view returns (address);
    function ownerOf(uint) external view returns (address);
    function summoner(uint) external view returns (uint _xp, uint _log, uint _class, uint _level);
}



interface DarkPlanetUserBaseLayer {
    function getSummonerState(uint256 summoner)external view returns(bool,uint256 state);
    function getSummonerInfo(uint256 summoner)external view  returns(
        bool r_result,
        uint256 r_state,
        uint256 tTime,
        uint256 rTime);
    function getSummonerInfo_MyLand(uint256 mySummoner,uint256 sIndex)external view  returns(
        bool r_result,
        uint256 r_state,
        uint256 tTime,
        uint256 rTime);
    function getSummonerAmount_MyLand(uint256 summoner)external view returns(bool,uint256);
    function getMaxSummonersAmount_Land()external view returns(uint256);
    function getActivePeriod()external view returns(uint256);
    function getLandLocationForSummoner(uint256 summoner) external view returns(bool,uint256);
}


contract DarkPlanetUserShowLayer {
    
    //main-Rarity: 0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb
    rarity constant rm = rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
    //main-Storage: 0x411409fF5c149499062AB86E158aB2945eF366e3
    RarityLandStorage constant rls = RarityLandStorage(0x411409fF5c149499062AB86E158aB2945eF366e3);
    //main-UserBaseLayer: 0xA9B2bEB203044Db3caFeFa67C599Ec93902C8Dec
    DarkPlanetUserBaseLayer constant ubl = DarkPlanetUserBaseLayer(0xA9B2bEB203044Db3caFeFa67C599Ec93902C8Dec);
   
    function isRarityOwner(uint256 summoner) internal view returns (bool) {
        address rarityAddress = rm.ownerOf(summoner);
        return rarityAddress == msg.sender;
    }

   function showLayber(uint256 rlTokenID) internal view returns (string memory) {
        
        (bool s_result,uint256 summoner) = rls.getSummoner(rlTokenID);
        string memory output;
        {
        if(s_result){
            // has land
            string[10] memory parts;
            {
                (
                    , 
                    string memory s_name,
                    string memory s_des,
                    ,
                ) = rls.loadLandInfo(summoner);
                (,bool tLandState) = rls.getLandState(summoner);
                (,uint256 income) = rls.getLandIncome(summoner);
                (,uint256 sAmount) = rls.getLandSummoners(summoner);
                (,uint256 lAmount) = ubl.getSummonerAmount_MyLand(summoner);
                parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
                parts[1] = string(abi.encodePacked("Rarity##DarkPlanet's land", '</text><text x="10" y="40" class="base">'));
                if(tLandState){
                    parts[2] = string(abi.encodePacked("Name:", " ", s_name, '</text><text x="10" y="60" class="base">'));
                }else{
                    parts[2] = string(abi.encodePacked("Name:", " ", "******", '</text><text x="10" y="60" class="base">'));
                }
                parts[3] = string(abi.encodePacked("Size:", " ", "1km * 1km", '</text><text x="10" y="80" class="base">'));
                parts[4] = string(abi.encodePacked("Land's coordinate:", " (",Base64.toString(rlTokenID * 1000),",",Base64.toString(0),")",  '</text><text x="10" y="100" class="base">'));
                parts[5] = string(abi.encodePacked("Earn: ", Base64.toString(income/1e18), " ftm", '</text><text x="10" y="120" class="base">'));
                parts[6] = string(abi.encodePacked("Summoner: ",Base64.toString(lAmount), " summoners are activated in my land.", '</text><text x="77" y="140" class="base">'));
                parts[7] = string(abi.encodePacked(Base64.toString((sAmount - lAmount))," summoners are dead in my land.", '</text><text x="10" y="160" class="base">'));
                parts[8] = string(abi.encodePacked("Des:", " ", s_des, '</text><text x="10" y="180" class="base">'));
                parts[9] = '</text></svg>';
            }
            output = string(abi.encodePacked(   parts[0], 
                                                parts[1], 
                                                parts[2],
                                                parts[3], 
                                                parts[4], 
                                                parts[5],
                                                parts[6],
                                                parts[7],
                                                parts[8],
                                                parts[9]
                                            )
                            );
        }else{
            //no land
            string[4] memory parts;
            parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
            parts[1] = string(abi.encodePacked("Rarity##DarkPlanet's land", '</text><text x="10" y="40" class="base">'));
            parts[2] = string(abi.encodePacked("Des:", " ", "You have no land .", '</text><text x="10" y="60" class="base">'));
            parts[3] = '</text></svg>';
            output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        }
        }

        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DarkPlanet', '", "description": "DarkPlanet is a strategy game based on Rarity. ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
    
    function showInfo_noLand()internal pure returns(string memory){
        string[4] memory parts;
        string memory output;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = string(abi.encodePacked("Rarity##DarkPlanet's land", '</text><text x="10" y="40" class="base">'));
        parts[2] = string(abi.encodePacked("Des:", " ", "You have no land .", '</text><text x="10" y="60" class="base">'));
        parts[3] = '</text></svg>';
        output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DarkPlanet', '", "description": "DarkPlanet is a strategy game based on Rarity. ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
    
    function showInfo_origin() internal pure returns(string memory){
        string[5] memory parts;
        string memory output;
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = string(abi.encodePacked("Rarity##DarkPlanet's land", '</text><text x="10" y="40" class="base">'));
        parts[2] = string(abi.encodePacked(" ", "You are currently at the origin. ", '</text><text x="10" y="60" class="base">'));
        parts[3] = string(abi.encodePacked(" ", "Move the coordinates to enter other people's land.", '</text><text x="10" y="80" class="base">'));
        parts[4] = '</text></svg>';
        output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DarkPlanet', '", "description": "DarkPlanet is a strategy game based on Rarity. ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
   
     //my land
    function landInfo_MyLand(uint256 summoner) public view returns(string memory){
        (bool result,uint256 lIndex) = rls.getLandIndex(summoner);
        if(!result){
            return showInfo_noLand();
        }
        return showLayber(lIndex);
    }
    
    
    //Get land information for my current location
    function landInfo_MyLocation(uint256 summoner) public view returns(string memory){
        (bool result,uint256 lIndex) = ubl.getLandLocationForSummoner(summoner);
        if(result){
            return showLayber(lIndex);
        }
        return showInfo_origin();
    }
    
    //summoner's info in the land
    function summonerInfo_MyLand(uint256 mySummoner,uint256 sIndex) public view returns(string memory){
        (
        bool r_result,
        uint256 r_state,
        uint256 tTime,
        uint256 rTime) = ubl.getSummonerInfo_MyLand(mySummoner,sIndex);
        if(!r_result){
            return "Parameter error .";
        }
        if(r_state == 0){
            return "r_result error . ";
        }
        string[9] memory parts;
        string memory output;
        string memory stateDes;
        if(r_state == 1){
            stateDes = "safe";
        }else{
            stateDes = "dangerous";
        }
        (
            , 
            ,
            string memory s_des,
            ,
        ) = rls.loadLandInfo(mySummoner);
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = string(abi.encodePacked("Rarity##DarkPlanet", '</text><text x="10" y="40" class="base">'));
        parts[2] = string(abi.encodePacked("This is the information of the summoner in my land.", '</text><text x="10" y="60" class="base">'));
        parts[3] = string(abi.encodePacked("Index: ",Base64.toString(sIndex) , '</text><text x="10" y="80" class="base">'));
        parts[4] = string(abi.encodePacked("Time on this land: ",Base64.toString(tTime/60),"min" , '</text><text x="10" y="100" class="base">'));
        parts[5] = string(abi.encodePacked("Time remaining: ",Base64.toString(rTime/60),"min" , '</text><text x="10" y="120" class="base">'));
        parts[6] = string(abi.encodePacked("Summoner status: ",stateDes , '</text><text x="10" y="140" class="base">'));
        parts[7] = string(abi.encodePacked("Des: ", s_des, '</text><text x="10" y="160" class="base">'));
        parts[8] = '</text></svg>';
        output = string(abi.encodePacked(   parts[0], 
                                            parts[1], 
                                            parts[2],
                                            parts[3], 
                                            parts[4], 
                                            parts[5],
                                            parts[6],
                                            parts[7],
                                            parts[8]
                                        )
                        );
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DarkPlanet', '", "description": "DarkPlanet is a strategy game based on Rarity. ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
    
    
    //summoner's info
    function summonerInfo_Me(uint256 summoner) public view returns(string memory){
        (
        bool r_result,
        uint256 r_state,
        uint256 tTime,
        uint256 rTime) = ubl.getSummonerInfo(summoner);
        if(!r_result){
            return "Parameter error .";
        }
        
        string[8] memory parts;
        string memory output;
        string memory stateDes;
        if(r_state == 1){
            stateDes = "safe";
        }else if(r_state == 0){
            stateDes = "dead";
        }else{
            stateDes = "dangerous";
        }
        
        parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
        parts[1] = string(abi.encodePacked("Rarity##DarkPlanet##Summoner's info", '</text><text x="10" y="40" class="base">'));
        parts[2] = string(abi.encodePacked("Summoner status: ",stateDes, '</text><text x="10" y="60" class="base">'));
        parts[3] = string(abi.encodePacked("Time on this land: ",Base64.toString(tTime/60),"min" , '</text><text x="10" y="80" class="base">'));
        parts[4] = string(abi.encodePacked("Time remaining: ",Base64.toString(rTime/60),"min" , '</text><text x="10" y="100" class="base">'));
        parts[5] = string(abi.encodePacked("Des: ","If you are in danger," , '</text><text x="40" y="120" class="base">'));
        parts[6] = string(abi.encodePacked("the landowner has the right to evict you." , '</text><text x="10" y="140" class="base">'));
        parts[7] = '</text></svg>';
        output = string(abi.encodePacked(   parts[0], 
                                            parts[1], 
                                            parts[2],
                                            parts[3], 
                                            parts[4], 
                                            parts[5],
                                            parts[6],
                                            parts[7]
                                        )
                        );
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "DarkPlanet', '", "description": "DarkPlanet is a strategy game based on Rarity. ", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
    }
}