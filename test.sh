#!/bin/sh

workdir=$(mktemp -d)
SRC=$workdir/src
DEST=$workdir/dest
mkdir $SRC $DEST

output=$workdir/program-output

touch	$SRC/0000000000000000000000000000000000000000000000000000000000000000 \
	$SRC/0000000000000000000000000000000000000000000000000000000000000001 \
	$SRC/0000000000000000000000000000000000000000000000000000000000000002 \
	$SRC/0000000000000000000000000000000000000000000000000000000000000003 \
	$DEST/0000000000000000000000000000000000000000000000000000000000000004 \
	$DEST/0000000000000000000000000000000000000000000000000000000000000005 \
	$DEST/0000000000000000000000000000000000000000000000000000000000000006 \
	$DEST/0000000000000000000000000000000000000000000000000000000000000007 \

rm -f /tmp/git-lfs-agent-rclone-*

cat <<EOF | ./git-lfs-agent-rclone 2>$output 1>&2 $DEST
{"event":"init"}
{"event":"upload","oid":"0000000000000000000000000000000000000000000000000000000000000000","path":"$SRC/0000000000000000000000000000000000000000000000000000000000000000"}
{"event":"download","oid":"0000000000000000000000000000000000000000000000000000000000000004"}
{"event":"upload","oid":"0000000000000000000000000000000000000000000000000000000000000001","path":"$SRC/0000000000000000000000000000000000000000000000000000000000000001"}
{"event":"download","oid":"0000000000000000000000000000000000000000000000000000000000000005"}
{"event":"terminate"}
EOF

cat <<EOF | ./git-lfs-agent-rclone 2>$output 1>&2 $DEST/
{"event":"init"}
{"event":"upload","oid":"0000000000000000000000000000000000000000000000000000000000000002","path":"$SRC/0000000000000000000000000000000000000000000000000000000000000002"}
{"event":"download","oid":"0000000000000000000000000000000000000000000000000000000000000006"}
{"event":"upload","oid":"0000000000000000000000000000000000000000000000000000000000000003","path":"$SRC/0000000000000000000000000000000000000000000000000000000000000003"}
{"event":"download","oid":"0000000000000000000000000000000000000000000000000000000000000007"}
{"event":"terminate"}
EOF

# Move the tmp files (git-lfs takes care of this in practice)
for file in /tmp/git-lfs-agent-rclone-*; do
  mv $file $SRC/${file#/tmp/git-lfs-agent-rclone-}
done

diff $SRC $DEST

if [ $? -ne 0 ]; then
  echo >&2 KO, program output:
  cat $output
  exit 1
fi

echo OK

rm -rf $workdir
