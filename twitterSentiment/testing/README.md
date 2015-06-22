# Testing

### Test a single url
    siege -c200 -b -t3M "http://localhost/game/tweets?time=min"

### Test multiple urls
More realistic simulation of randomly hitting a url from a list.

    siege -c200 -b -t3M -i -f urls.txt
