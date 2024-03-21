function get_filename_from_full_path(fullPath) {
  const startIndex =
    fullPath.indexOf('\\') >= 0 ?
      fullPath.lastIndexOf('\\') :
      fullPath.lastIndexOf('/');
  let filename = fullPath.substring(startIndex);
  if (filename.indexOf('\\') === 0 || filename.indexOf('/') === 0) {
    filename = filename.substring(1);
  }
  return filename
}
