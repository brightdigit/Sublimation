import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "You're connected"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
}
