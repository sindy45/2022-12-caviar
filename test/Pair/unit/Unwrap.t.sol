// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../../shared/Fixture.t.sol";
import "../../../src/Caviar.sol";

contract UnwrapTest is Fixture {
    uint256[] public tokenIds;

    function setUp() public {
        bayc.setApprovalForAll(address(p), true);

        for (uint256 i = 0; i < 5; i++) {
            bayc.mint(address(this), i);
            tokenIds.push(i);
        }

        p.wrap(tokenIds);
    }

    function testItTransfersTokens() public {
        // act
        p.unwrap(tokenIds);

        // assert
        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(bayc.ownerOf(i), address(this), "Should have sent bayc to sender");
        }
    }

    function testItBurnsFractionalTokens() public {
        // arrange
        uint256 expectedFractionalTokensBurned = tokenIds.length * 1e18;
        uint256 balanceBefore = p.balanceOf(address(this));
        uint256 totalSupplyBefore = p.totalSupply();

        // act
        p.unwrap(tokenIds);

        // assert
        assertEq(
            balanceBefore - p.balanceOf(address(this)),
            expectedFractionalTokensBurned,
            "Should have burned fractional tokens from sender"
        );

        assertEq(
            totalSupplyBefore - p.totalSupply(), expectedFractionalTokensBurned, "Should have burned fractional tokens"
        );
    }
}