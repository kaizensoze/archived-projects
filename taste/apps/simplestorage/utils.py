from boto.exception import S3ResponseError

def S3Push(name, path, acl, bucket, key, secret):
    from boto.s3.connection import S3Connection

    connection = S3Connection(key, secret)
    try:
        bucket = connection.get_bucket(bucket)
    except S3ResponseError:
        raise IOError("% bucket does not exist.  Create bucket before using storage backend." % bucket)

    file = open(path)

    k = bucket.new_key(name)
    k.set_contents_from_file(file, policy=acl)
