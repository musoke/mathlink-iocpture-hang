using IOCapture
using Logging
using MathLink

function hangs()
    @debug "Before capture"
    c = IOCapture.capture() do
        MathLink._defaultlink()
    end
    @debug "After capture" c
end

ENV["JULIA_DEBUG"] = "IOCapture,MathLink"

# W`Sin`
hangs()
