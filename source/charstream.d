/**
 * `charstream.d` provides a character input stream.
 *
 * Author: H Paterson.
 * Copyright: H Paterson, 2020.
 * License: BSL-1.0.
 */

import std.stdio;

/**
 * Converts a column number (in the source file) into an
 * index into the internal streaming buffer.
 *
 * `bufferIndex` is just a wrapper which deals with the
 * text column numbers starting from 1, and the internal
 * buffers being indexed from 0.
 *
 * Parameters:
 *    column = The text column number to convert to an index.
 *
 * Returns: The buffer index corosponding to the `column`.
 */
@safe private size_t bufferIndex(size_t column)
{
    assert(column > 0);
    return column - 1;
}

///
unittest
{
    assert(bufferIndex(1) == 0);
    assert(bufferIndex(14) == 13);
}

/**
 * `CharStream` provides a character stream input.
 *
 * `CharStream` is a wrapper around file, with additional
 * eror checking, and line/column number tracking.
 *
 * New line symbols such as *LF* and *CR* (`\n` and `\r`)
 * are significant characters to the question of code styling,
 * so the CharStream includes these characters in the stream.
 */
class CharStream
{

    /** `_source` is the file which characters is read from. */
    private File _source;

    /** `_line` is the line the `CharStream` is reading from. */
    private size_t _line = 1;

    /** `_column` is the column the `CharStream is reading from. */
    private size_t _column = 1;

    /** `_buffer` stores lines read in from the file. */
    private char[] _buffer;

    /**
     * Initialises a new `CharStream` using the provided
     * file as the input source.
     *
     * Parameters:
     *     file = A source for the character stream.
     */
    public this(File file)
    {
        this._source = file;
        this._source.readln(this._buffer);
    }

    unittest
    {
        File f = File.tmpfile();
        CharStream stream = new CharStream(f);
        assert(stream);
    }

    /**
     * Indicates the name of the file we're streaming from.
     *
     * Warning: The name of the underlying file can be null
     * in some situations, depending how the source File was
     * created. See the [D file documentation]
     * (https://dlang.org/phobos/std_stdio.html#.File.name)
     * for more information.
     *
     * Return: The name of the source file for the stream. 
     */
    @property @safe public string name() const
    {
        return this._source.name;
    }

    ///
    unittest
    {
        string filename = "testfile";
        CharStream s = new CharStream(File(filename, "w+"));
        assert(s.name == filename);
        s = new CharStream(File.tmpfile());
        assert(s.name == null);
    }

    /**
     * Indicates the line the stream's "cursor" is on.
     *
     * Returns: The line in the source file currently being
     *          streamed.
     */
    @property @safe public size_t line() const
    {
        return this._line;
    }

    unittest
    {
        File f = File.tmpfile();
        f.write("\nd");
        f.seek(0);
        CharStream s = new CharStream(f);
        assert(s.line == 1);
        s.popFront();
        assert(s.line == 2);
    }

    /**
     * Indicates the column the stream's "cursor" is on.
     *
     * Returns: The column the in the source file which
     *          is at the front of the stream/range.
     */
    @property @safe public size_t column() const
    {
        return this._column;
    }

    unittest
    {
        File f = File.tmpfile();
        f.write("a\nbe");
        f.seek(0);
        CharStream s = new CharStream(f);
        assert(s.column == 1);
        s.popFront();
        assert(s.column == 2);
        s.popFront();
        s.popFront();
        assert(s.column == 2);
    }

    /**
     * Indicates if the stream can provide more input.
     *
     * `empty` is part of the `InputRange`interface, and
     * checks if the underlying file has any more characters
     * to stream.
     *
     * Returns: True if no more characters can be streamed.
     */
    @property @safe public bool empty() const
    {
        /* Test the underling file is empty, and we've
         * consumed the entire buffer. This is a bit ugly.
         * We should rewrite the file & buffer system.
         */
        return this._source.eof() && bufferIndex(this.column) == this._buffer.length;
    }

    unittest
    {
        File f = File.tmpfile();
        f.write("a");
        f.seek(0);
        CharStream s = new CharStream(f);
        assert(s.empty == false);
        s.popFront();
        s.popFront();
        assert(s.empty == true);
    }

    /**
     * Peek at the next character in the stream.
     *
     * `front` is part of the Range interface. `front` does
     * not guarentee an element actually exists to return.
     * Users should call `empty` first to check an elemen is
     * available.
     *
     * Returns: The next character in the stream.
     */
    @property char front() const
    {
        return this._buffer[bufferIndex(this._column)];
    }

    unittest
    {
        File f = File.tmpfile();
        f.write("ab");
        f.seek(0);
        CharStream s = new CharStream(f);
        assert(s.front == 'a');
        assert(s.front == 'a');
        s.popFront();
        assert(s.front == 'b');
    }

    /**
     * Remove the next character from the stream.
     *
     * `popFront` consumes the next character from the
     * stream, and advances to the next character.
     *
     * `popFront` is part of the Range interface, so does
     * not actually return the character. You can read the
     * next character with `front()` or other Range access
     * methods if required.
     */
    void popFront()
    {
        this._column++;
        if (bufferIndex(this._column) >= this._buffer.length)
        {
            this._source.readln(this._buffer);
            this._column = 1;
            this._line++;
        }
    }
}
