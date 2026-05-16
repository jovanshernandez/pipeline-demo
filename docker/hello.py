import falcon


class HelloResource:
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.media = {
            "service": "pipeline-demo",
            "message": "Hello, World!",
        }


class HealthResource:
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.media = {
            "status": "ok",
        }


class Page2Resource:
    def on_get(self, req, resp):
        resp.status = falcon.HTTP_200
        resp.media = {
            "message": "This is the second page!",
        }


app = falcon.App()
app.add_route("/", HelloResource())
app.add_route("/health", HealthResource())
app.add_route("/page2", Page2Resource())
