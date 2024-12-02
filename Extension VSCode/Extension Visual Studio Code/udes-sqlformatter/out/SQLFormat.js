"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SQLFormat = void 0;
class SQLFormat {
    indentLevel;
    indentString;
    formattedSQL;
    constructor(indent = 4) {
        this.indentLevel = 0;
        this.indentString = ' '.repeat(indent);
        this.formattedSQL = [];
    }
    // Entry point to format the SQL
    format(sql) {
        this.formattedSQL = [];
        this.indentLevel = 0;
        // Split the SQL into tokens by spaces, newlines, or SQL symbols
        let tokens = this.tokenize(sql);
        // Format each token
        for (let token of tokens) {
            this.handleToken(token);
        }
        return this.formattedSQL.join('').trim();
    }
    // Tokenize the SQL input into meaningful parts (keywords, symbols, etc.)
    tokenize(sql) {
        const regex = /([(),;])/g; // Match common SQL symbols
        return sql
            .replace(/\s+/g, ' ') // Normalize whitespace
            .replace(regex, ' $1 ') // Add space around symbols
            .split(/\s+/); // Split on whitespace
    }
    // Handles each token and applies formatting rules
    handleToken(token) {
        token = token.toUpperCase();
        if (this.isNewLineKeyword(token)) {
            this.newLine();
            this.addToken(token);
            this.newLine();
        }
        else if (this.isComma(token)) {
            this.addToken(token);
            this.newLine();
        }
        else if (this.isBlockStart(token)) {
            this.addToken(token);
            this.indent();
            this.newLine();
        }
        else if (this.isBlockEnd(token)) {
            this.unindent();
            this.newLine();
            this.addToken(token);
        }
        else {
            this.addToken(token);
        }
    }
    // Checks if the token should start on a new line (e.g., SELECT, FROM)
    isNewLineKeyword(token) {
        const newLineKeywords = ['SELECT', 'FROM', 'WHERE', 'JOIN', 'ORDER BY', 'GROUP BY', 'INSERT', 'UPDATE', 'DELETE', 'SET', 'VALUES'];
        return newLineKeywords.includes(token);
    }
    // Checks if the token is a comma, which should be followed by a new line
    isComma(token) {
        return token === ',';
    }
    // Checks if the token is the start of a block (e.g., a parenthesis)
    isBlockStart(token) {
        return token === '(';
    }
    // Checks if the token is the end of a block (e.g., a closing parenthesis)
    isBlockEnd(token) {
        return token === ')';
    }
    // Adds a token to the formatted SQL
    addToken(token) {
        this.formattedSQL.push(token + ' ');
    }
    // Adds a newline and proper indentation
    newLine() {
        this.formattedSQL.push('\n' + this.indentString.repeat(this.indentLevel));
    }
    // Increases the indentation level
    indent() {
        this.indentLevel++;
    }
    // Decreases the indentation level
    unindent() {
        if (this.indentLevel > 0) {
            this.indentLevel--;
        }
    }
}
exports.SQLFormat = SQLFormat;
//# sourceMappingURL=SQLFormat.js.map