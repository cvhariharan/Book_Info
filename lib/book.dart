class Book {
  String title, description, url, published, publisher;
  List<dynamic> authors, categories;

  Map details;
  Book(this.details) {
    this.title = details["volumeInfo"]["title"];
    this.description = details["volumeInfo"]["description"];
    this.authors = details["volumeInfo"]["authors"];
    this.categories = details["volumeInfo"]["categories"];
    this.publisher = details["volumeInfo"]["publisher"];
    this.published = details["volumeInfo"]["publishedDate"];
    if (details["volumeInfo"]["subtitle"] != null) {
      this.title += " " + details["volumeInfo"]["subtitle"];
    }
  }

  String getAuthors() {
    String authorNames = "";
    authors.forEach((name) {
      authorNames += name.toString() + ", ";
    });
    return authorNames;
  }

  String getCategories() {
    String cate = "";
    categories.forEach((category) {
      cate += category.toString() + ", ";
    });
    return cate;
  }
}
