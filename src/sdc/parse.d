/**
 * Copyright 2010 Bernard Helyer
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdl.d for more details.
 * 
 * parse.d: translate a TokenStream into a parse tree.
 */ 
module sdc.parse;

import std.string;
import std.path;

import sdc.compilererror;
import sdc.tokenstream;
import sdc.ast.base;
import sdc.ast.sdcmodule;


Module parse(TokenStream tstream)
{
    return parseModule(tstream);
}

private:

void match(TokenStream tstream, TokenType type)
{
    if (tstream.peek.type != type) {
        error(tstream.peek.location, format("expected '%s', got '%s'",
                                            tokenToString[type],
                                            tokenToString[tstream.peek.type]));
    }
    tstream.getToken();
}

Module parseModule(TokenStream tstream)
{
    auto mod = new Module();
    match(tstream, TokenType.Begin);
    mod.moduleDeclaration = parseModuleDeclaration(tstream);
    return mod;
}                                        

ModuleDeclaration parseModuleDeclaration(TokenStream tstream)
{
    auto modDec = new ModuleDeclaration();
    if (tstream.peek.type == TokenType.Module) {
        // Explicit module declaration.
        match(tstream, TokenType.Module);
        modDec.name = parseQualifiedName(tstream);
        match(tstream, TokenType.Semicolon);
    } else {
        // Implicit module declaration.
        modDec.name = new QualifiedName();
        auto token = new Token();
        token.type = TokenType.Identifier;
        token.location = tstream.peek.location;
        token.value = basename(tstream.filename, "." ~ getExt(tstream.filename));
        auto ident = new Identifier();
        ident.token = token;
        modDec.name.identifiers ~= ident;
    }
    return modDec;
}

QualifiedName parseQualifiedName(TokenStream tstream)
{
    auto name = new QualifiedName();
    auto ident = new Identifier();
    while (true) {
        name.identifiers ~= parseIdentifier(tstream);
        if (tstream.peek.type == TokenType.Dot) {
            match(tstream, TokenType.Dot);
        } else {
            break;
        }
    }
    return name;
}

Identifier parseIdentifier(TokenStream tstream)
{
    auto ident = new Identifier();
    ident.token = tstream.peek;
    match(tstream, TokenType.Identifier);
    return ident;
}
