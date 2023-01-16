![](https://github.com/ViacomInc/URLSessionDecodable/workflows/Run%20tests/badge.svg?branch=master)

# URLSessionDecodable

A swift package for adding decoding functionality to `URLSession`. It is a very small but handful library, that solves the common pattern of deserialization of a response, and fallback on another message format in case of an HTTP error.

We have been using it in some form over the years at former Viacom, now [Paramount](https://www.paramount.com/). Since Swift Package Manager support in Xcode 11.0, we use it on production in several projects.

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```
dependencies: [
    .package(url: "https://github.com/ViacomInc/URLSessionDecodable.git", .upToNextMajor(from: "0.1.0"))
]
```

## Usage

Example usage, fetching a response that has a specific error format if error is handled by a backend:

```
struct AnimalsResponse: Decodable {
    let name: String
}

struct AnimalsError: Error {
    // optional, there are also other errors than the ones handled by a backend 
    let errorResponse: ErrorResponse? 
}

struct ErrorResponse: Decodable {
    let userMessage: String
}

func getFavoriteAnimals(urlSession: URLSession = .shared,
                        completionHandler: (Result<AnimalsResponse, AnimalsError>) -> Void) -> Cancelable {
	
	let url = URL(string: "https://myservice.com/favoriteAnimals")!
	return urlSession.decodableTask(with: url,
	                                method: .get,
	                                parameters: nil,
	                                headers: nil,
	                                decoder: JSONDecoder()) { result in
	    
	    switch result {
	    	case .success(let animals):
	    	   completionHandler(.success(animals))
	    	case .failure(let error):
	    	   let animalsFetchError: ErrorResponse? = error.decodeResponse(using: JSONDecoder())
	    	   completionHandler(.failure(AnimalsError(errorResponse: animalsFetchError)))
	    }
	}
}
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## License

URLSessionDecodable is released under the Apache 2.0 license. [See LICENSE](LICENSE) for details.
