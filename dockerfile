FROM debian
RUN touch file.txt
RUN rm -f file.txt
