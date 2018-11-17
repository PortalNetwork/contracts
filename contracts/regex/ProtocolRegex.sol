pragma solidity ^0.4.24;

contract ProtocolRegex {
    struct State {
        bool accepts;
        function (byte) internal pure returns (State memory) func;
    }

    string public constant regex = "[a-z]{2,}";

    function s0(byte c) internal pure returns (State memory) {
        c = c;
        return State(false, s0);
    }

    function s1(byte c) internal pure returns (State memory) {
        if (c >= 97 && c <= 122) {
            return State(false, s2);
        }

        return State(false, s0);
    }

    function s2(byte c) internal pure returns (State memory) {
        if (c >= 97 && c <= 122) {
            return State(true, s3);
        }

        return State(false, s0);
    }

    function s3(byte c) internal pure returns (State memory) {
        if (c >= 97 && c <= 122) {
            return State(true, s4);
        }

        return State(false, s0);
    }

    function s4(byte c) internal pure returns (State memory) {
        if (c >= 97 && c <= 122) {
            return State(true, s4);
        }

        return State(false, s0);
    }

    function matches(string input) public pure returns (bool) {
        State memory cur = State(false, s1);

        for (uint i = 0; i < bytes(input).length; i++) {
            byte c = bytes(input)[i];

            cur = cur.func(c);
        }

        return cur.accepts;
    }
}