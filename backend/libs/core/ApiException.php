<?php

/**
 * Exception whose message is safe to show to the client.
 */
class ApiException extends RuntimeException
{
    public function __construct(string $message, private int $status = 400)
    {
        parent::__construct($message);
    }

    public function getStatus(): int
    {
        return $this->status;
    }
}
