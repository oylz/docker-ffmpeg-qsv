# docker-ffmpeg-qsv

## WIP

```sh
git clone https://github.com/pocka/docker-ffmpeg-qsv
cd docker-ffmpeg-qsv
cp /path/to/MediaServerStudio*.tar.gz ./
cp /path/to/SRB4_linux64.zip ./
cp /path/to/sys_analyzer_linux.py_.tgz ./
make

docker run -v /data:/data pocka/ffmpeg-qsv -i /data/foo.ts -c:v h264_qsv -look_ahead 0 -q 20 /data/foo.mp4
```
