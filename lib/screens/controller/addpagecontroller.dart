List<Map<String, dynamic>> blogs = [];

void addBlog(
    {required title, required author, required content, required date}) {
  blogs.add(
      {'title': title, 'author': author, 'content': content, 'date': date});
}
