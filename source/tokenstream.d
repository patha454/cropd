/**
 * `tokenstream.d` provides a system to read Backus-Naur
 * Form tokens from a file.
 *
 * Deprecated: `tokenstream.d` is not considered a production
 * grade module. The module is intended to bootstrap a
 * BNF parser, which can then be used to pass grammars.
 * Everthing about this file, including its existance, is
 * subject to change without notice.
 *
 * Author: H Paterson.
 * Copyright: H Paterson, 2020.
 * License: BSL-1.0.
 */

/**
 * `TokenType` provides an indication of the type of token
 * found. We leave the task of forming Abstract Syntax
 * Trees to other, more sophisticated modules.
 */
enum TokenType
{
    Comment,
    VariableName,
    OpAssign,
    OpOr,
    Literal
}

/*
 * 
class BNFToken
{
    TokenType type;
    string value;
}


