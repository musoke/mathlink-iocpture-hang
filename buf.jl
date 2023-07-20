using MathLink

function boring()
    1 + 2
end

function mathlink()
    weval("Sin[0]")
end

function hang(f)
    pipe = Pipe()
    @debug "Pipe created" f = string(f) pipe pipe.in pipe.out

    default_stdout = stdout
    Base.link_pipe!(pipe; reader_supports_async = true, writer_supports_async = true)
    pe_stdout = pipe.in
    redirect_stdout(pe_stdout)

    output = IOBuffer()
    buffer_redirect_task = @async write(output, pipe)

    val = f()
    @debug "Value computed" f = string(f) val
    @debug "Pipe in use" f = string(f) pipe pipe.in pipe.out

    redirect_stdout(default_stdout)
    close(pe_stdout)

    if timedwait(() -> istaskdone(buffer_redirect_task), 30) === :ok
        @info "wait succeeded" f = string(f) pipe pipe.in pipe.out
    else
        @warn "wait timed out after 30 seconds" f = string(f) pipe pipe.in pipe.out
        close(pipe.out)
        wait(buffer_redirect_task)
        @info "wait succeeded after closing pipe.out" f = string(f) pipe pipe.in pipe.out
    end

    @debug "Contents of redirected stdout" String(take!(output))
end

ENV["JULIA_DEBUG"] = Main

hang(boring)
print("\n\n")
hang(mathlink)
