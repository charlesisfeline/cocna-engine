-- this gets called starts when the level loads.
function start(song) -- arguments, the song name

end

-- this gets called every frame
function update(elapsed) -- arguments, how long it took to complete a frame
    
end

-- this gets called every beat
function beatHit(beat) -- arguments, the current beat of the song
    camGame:tweenZoom(1.7,(crochet * 7) / 1000)
end

-- this gets called every step
function stepHit(step) -- arguments, the current step of the song (4 steps are in a beat)
    scrollspeed = scrollspeed + 0.001
    print(scrollspeed)
end