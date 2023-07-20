using IOCapture
using Logging
using MathLink

function hangs()
    @debug "Before capture"
    c = IOCapture.capture() do
        W`Sin`
    end
    @debug "After capture" c
end

function hangs_mwe()
    @debug "Before capture"
    c = iocapture_mwe() do
        W`Sin`
    end
    @debug "After capture" c
end

function iocapture_mwe(f)
    @debug "Entered"
    default_stdout = stdout
    # default_stderr = stderr

    pipe = Pipe()
    Base.link_pipe!(pipe; reader_supports_async = true, writer_supports_async = true)

    pe_stdout = pipe.in
    # pe_stderr = pipe.in

    redirect_stdout(pe_stdout)
    # redirect_stderr(pe_stderr)

    output = IOBuffer()
    buffer_redirect_task = @async write(output, pipe)

    yield()
    value = f()
    @debug "got value" value

    println("OURPUT PRINT")
    output = String(take!(output)),
    @debug "captured output" output typeof(output)

    redirect_stdout(default_stdout)
    # redirect_stderr(default_stderr)

    close(pe_stdout)
    # close(pe_stderr)

    wait(buffer_redirect_task)  # No hang if this line is commented

    @debug "Waited output" output typeof(output)

    (value, output)
end

ENV["JULIA_DEBUG"] = Main

# W`Sin`
hangs_mwe()
