pragma solidity ^0.4.24;

contract ProtocolRegex {
    struct ProtocolState {
        bool accepts;
        function (byte) internal pure returns (ProtocolState memory) func;
    }

    string public constant regex = "[a-z]{2,}";

    function p0(byte c) internal pure returns (ProtocolState memory) {
        c = c;
        return ProtocolState(false, p0);
    }

    function p1(byte c) internal pure returns (ProtocolState memory) {
        if (c >= 97 && c <= 122) {
            return ProtocolState(false, p2);
        }

        return ProtocolState(false, p0);
    }

    function p2(byte c) internal pure returns (ProtocolState memory) {
        if (c >= 97 && c <= 122) {
            return ProtocolState(true, p3);
        }

        return ProtocolState(false, p0);
    }

    function p3(byte c) internal pure returns (ProtocolState memory) {
        if (c >= 97 && c <= 122) {
            return ProtocolState(true, p4);
        }

        return ProtocolState(false, p0);
    }

    function p4(byte c) internal pure returns (ProtocolState memory) {
        if (c >= 97 && c <= 122) {
            return ProtocolState(true, p4);
        }

        return ProtocolState(false, p0);
    }

    function protocolMatches(string input) public pure returns (bool) {
        ProtocolState memory cur = ProtocolState(false, p1);

        for (uint i = 0; i < bytes(input).length; i++) {
            byte c = bytes(input)[i];

            cur = cur.func(c);
        }

        return cur.accepts;
    }
}