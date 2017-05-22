Changelog
------------------

HEAD
------------------
* Bugfix - Fix an issue where metric assignments on different threads were erroring when submitting to Librato (https://github.com/ello/kinesis-stream-reader/pull/18)
* Bugfix - Don't attempt to fire up Librato when credentials are not specified

0.3.0 (2017-05-05)
------------------
* Feature - Update `run!` to pass in an hash (instead of only the schema_name) that contains the `schema_name`, `raw_data`, `sequence_number`, and `shard_id`. 
